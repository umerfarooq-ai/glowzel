import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:Glowzel/Constant/app_color.dart';
import 'package:Glowzel/module/scan/skin_health1.dart';
import 'package:Glowzel/ui/button/custom_elevated_button.dart';
import 'package:Glowzel/ui/widget/nav_router.dart';
import 'package:image/image.dart' as img;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

import '../../core/exceptions/api_error.dart';
import '../../core/network/dio_client.dart';
import '../../core/security/secure_auth_storage.dart';
import '../../core/storage_services/storage_service.dart';
import '../authentication/repository/auth_repository.dart';
import '../authentication/repository/session_repository.dart';
import '../user/models/user_model.dart';
import '../user/repository/user_account_repository.dart';

import 'cubit/skin_analysis_cubit.dart';
import 'cubit/skin_analysis_state.dart';
import 'model/skin_analysis_input.dart';

class ScanFace1 extends StatelessWidget {
  const ScanFace1({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SkinAnalysisCubit(authRepository: GetIt.I<AuthRepository>()),
      child: const ScanFace1View(),
    );
  }
}

class ScanFace1View extends StatefulWidget {
  const ScanFace1View({super.key});

  @override
  State<ScanFace1View> createState() => _ScanFace1ViewState();
}

class _ScanFace1ViewState extends State<ScanFace1View>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  Timer? _processingTimer;

  // Camera
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _cameraReady = false;
  bool _streaming = false;
  bool _capturing = false;
  StreamSubscription? _imageStreamSubscription;

  late final FaceDetector _faceDetector;
  bool _isProcessingFrame = false;
  Face? _latestFace;

  late final AnimationController _scanAnimController;
  late final Animation<double> _scanAnimation;

  late AuthRepository authRepository;
  late SessionRepository sessionRepository;
  UserModel? _me;
  bool _loadingProfile = true;
  bool _disposed = false;

  String _instruction = 'Center your face in the oval';
  double _complianceProgress = 0.0;
  int _consecutiveGoodFrames = 0;
  static const int kFramesToAutoCapture = 12;

  static const double kCenterTolerance = 0.13;
  static const double kMinFaceSize = 0.30;
  static const double kMaxFaceSize = 0.80;
  static const double kMaxYawDeg = 10;
  static const double kMaxRollDeg = 10;
  static const double kMaxPitchDeg = 12;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _scanAnimController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 3)
    )..repeat();
    _scanAnimation = CurvedAnimation(
        parent: _scanAnimController,
        curve: Curves.linear
    );

    _initRepositories();

    _faceDetector = GoogleMlKit.vision.faceDetector(
      FaceDetectorOptions(

        enableContours: false,
        enableLandmarks: false,
        performanceMode: FaceDetectorMode.fast,
        enableClassification: false,
        enableTracking: false,
      ),
    );

    _loadProfileThenInit();
  }

  void _initRepositories() {
    sessionRepository = SessionRepository(
      storageService: GetIt.I<StorageService>(),
      authSecuredStorage: GetIt.I<AuthSecuredStorage>(),
    );
    authRepository = AuthRepository(
      dioClient: GetIt.I<DioClient>(),
      authSecuredStorage: GetIt.I<AuthSecuredStorage>(),
      userAccountRepository: GetIt.I<UserAccountRepository>(),
      sessionRepository: GetIt.I<SessionRepository>(),
    );
  }

  Future<void> _loadProfileThenInit() async {
    if (_disposed) return;

    try {
      final token = await sessionRepository.getToken();
      if (token == null) throw ApiError(message: 'Token not found');
      _me = await authRepository.getMe();
    } catch (e) {
      debugPrint('Profile loading error: $e');
      _me = null;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load user profile')),
        );
      }
    } finally {
      _loadingProfile = false;
      if (mounted) setState(() {});
      if (_me != null) {
        await Future.delayed(const Duration(milliseconds: 250));
        await _initCamera();
      }
    }
  }

  Future<void> _initCamera() async {
    if (_disposed) return;

    try {
      _cameras = await availableCameras();
      debugPrint('Available cameras: ${_cameras.map((c) => c.name).join(', ')}');
      if (_cameras.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No cameras found on this device.'),
              duration: Duration(seconds: 5),
            ),
          );
        }
        return;
      }

      final frontCamera = _cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras.first,
      );

      bool success = await _initializeCameraControllerWithFormats(frontCamera);

      if (!success) {
        throw CameraException('No supported format', 'Could not initialize with any supported format.');
      }

    } on CameraException catch (e) {
      _showCameraError(e);
    } catch (e) {
      _showCameraError(e);
    }
  }

  Future<bool> _initializeCameraControllerWithFormats(CameraDescription camera) async {
    final formatsToTry = [
      ImageFormatGroup.yuv420,
      ImageFormatGroup.bgra8888,
    ];

    for (final format in formatsToTry) {
      try {
        _cameraController = CameraController(
          camera,
          ResolutionPreset.medium,
          enableAudio: false,
          imageFormatGroup: format,
        );

        await _cameraController!.initialize();

        if (_disposed) {
          _cameraController?.dispose();
          return false;
        }

        _cameraReady = true;
        if (mounted) setState(() {});
        await Future.delayed(const Duration(milliseconds: 250));
        await _startStream();
        return true; // Success!
      } catch (e) {
        debugPrint('Failed to initialize with format $format: $e');
        _cameraController?.dispose(); // Ensure a failed controller is disposed
      }
    }

    return false;
  }

  Future<void> _tryAlternativeImageFormat(CameraDescription camera) async {
    if (_disposed) return;

    try {
      debugPrint('Trying alternative image format: BGRA8888');
      _cameraController = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.bgra8888,
      );

      await _cameraController!.initialize();

      if (_disposed) {
        _cameraController?.dispose();
        return;
      }

      _cameraReady = true;
      if (mounted) setState(() {});
      await _startStream();

    } catch (e) {
      debugPrint('Alternative format also failed: $e');
      _cameraReady = false;
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to initialize camera with compatible format'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _startStream() async {
    if (_disposed || _cameraController == null || !_cameraController!.value.isInitialized) return;
    if (_streaming) return;

    _streaming = true;

    // The key change is here: we'll use a lock to ensure only one frame is processed at a time.
    _cameraController!.startImageStream((CameraImage image) async {
      // If we're already processing a frame, just return. This is what prevents the queue from building up.
      if (_disposed || !_streaming || _capturing || _isProcessingFrame) {
        return;
      }

      _isProcessingFrame = true;

      try {
        final inputImage = _toInputImage(image, _cameraController!.description.sensorOrientation);
        final faces = await _faceDetector.processImage(inputImage);

        if (_disposed) return;
        _latestFace = faces.isNotEmpty ? faces.first : null;
        _updateGuidance(image, _latestFace);
      } catch (e) {
        debugPrint('Face detection error: $e');
      } finally {
        _isProcessingFrame = false;
        if (mounted && !_disposed) {
          // We only call setState here to update the UI with the latest face data
          setState(() {});
        }
      }
    });
  }

  void _processImage(CameraImage image) async {
    if (_disposed || _isProcessingFrame) return;

    _isProcessingFrame = true;
    try {
      final inputImage = _toInputImage(image, _cameraController!.description.sensorOrientation);
      final faces = await _faceDetector.processImage(inputImage);

      if (_disposed) return;

      _latestFace = faces.isNotEmpty ? faces.first : null;
      _updateGuidance(image, _latestFace);
    } catch (e) {
      if (!_disposed) {
        debugPrint('Face detection error: $e');
        if (e.toString().contains('ImageFormat is not supported')) {
          await _stopStream();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Camera format not supported. Please try restarting the app.'),
                duration: Duration(seconds: 3),
              ),
            );
          }
          return;
        }
      }
    } finally {
      _isProcessingFrame = false;
      if (mounted && !_disposed) {
        setState(() {});
      }
    }
  }

  Future<void> _stopStream() async {
    if (!_streaming) return;
    _streaming = false;
    _processingTimer?.cancel();
    _processingTimer = null;
    try {
      await _cameraController?.stopImageStream();
    } catch (e) {
      debugPrint('Stop stream error: $e');
    }
  }

  Uint8List _yuv420toNV21(CameraImage image) {
    final int planeWidth = (image.width / 2).floor();
    final int planeHeight = (image.height / 2).floor();

    final Uint8List y = image.planes[0].bytes;
    final Uint8List u = image.planes[1].bytes;
    final Uint8List v = image.planes[2].bytes;

    final int uvSize = planeWidth * planeHeight;
    final Uint8List uv = Uint8List(2 * uvSize);

    for (int i = 0; i < planeHeight; i++) {
      for (int j = 0; j < planeWidth; j++) {
        uv[2 * (i * planeWidth + j) + 0] = v[i * planeWidth + j];
        uv[2 * (i * planeWidth + j) + 1] = u[i * planeWidth + j];
      }
    }

    final Uint8List result = Uint8List(y.length + uv.length);
    result.setAll(0, y);
    result.setAll(y.length, uv);

    return result;
  }

  InputImage _toInputImage(CameraImage image, int rotation) {
    try {
      final imageRotation = _rotationIntToInputImageRotation(rotation);
      final format = image.format.group;
      final size = Size(image.width.toDouble(), image.height.toDouble());

      if (format == ImageFormatGroup.yuv420) {
        final bytes = _yuv420toNV21(image);
        return InputImage.fromBytes(
          bytes: bytes,
          metadata: InputImageMetadata(
            size: size,
            rotation: imageRotation,
            format: InputImageFormat.nv21,
            bytesPerRow: image.planes[0].bytesPerRow,
          ),
        );
      } else if (format == ImageFormatGroup.bgra8888) {
        return _inputImageFromBGRA8888(image, imageRotation);
      } else {
        debugPrint('Unsupported image format: $format');
        throw const FormatException('Unsupported image format');
      }
    } catch (e) {
      debugPrint('Error creating InputImage: $e');
      rethrow;
    }
  }
  InputImage _inputImageFromYUV420(CameraImage image, InputImageRotation rotation) {
    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];

    final allBytes = WriteBuffer();

    final int yWidth = yPlane.bytesPerRow;
    final int yHeight = image.height;

    for (int i = 0; i < yHeight; i++) {
      allBytes.putUint8List(yPlane.bytes.sublist(i * yWidth, i * yWidth + image.width));
    }

    final int uvWidth = uPlane.bytesPerRow;
    final int uvHeight = image.height ~/ 2;

    for (int i = 0; i < uvHeight; i++) {
      for (int j = 0; j < image.width; j += 2) {
        allBytes.putUint8(vPlane.bytes[i * uvWidth + j]);
        allBytes.putUint8(uPlane.bytes[i * uvWidth + j]);
      }
    }

    return InputImage.fromBytes(
      bytes: allBytes.done().buffer.asUint8List(),
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: InputImageFormat.nv21,
        bytesPerRow: image.width,
      ),
    );
  }

  InputImage _inputImageFromBGRA8888(CameraImage image, InputImageRotation rotation) {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return InputImage.fromBytes(
      bytes: allBytes.done().buffer.asUint8List(),
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: InputImageFormat.bgra8888,
        bytesPerRow: image.width * 4,
      ),
    );
  }

  InputImage _handleYUV420Format(
      CameraImage image, Size size, InputImageRotation rotation, InputImageFormat format) {
    final plane = image.planes[0];
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: size,
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  InputImage _handleBGRA8888Format(
      CameraImage image, Size size, InputImageRotation rotation) {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return InputImage.fromBytes(
      bytes: allBytes.done().buffer.asUint8List(),
      metadata: InputImageMetadata(
        size: size,
        rotation: rotation,
        format: InputImageFormat.bgra8888, bytesPerRow: 20,
      ),
    );
  }

  InputImage _handleUnsupportedFormat(
      CameraImage image, Size size, InputImageRotation rotation) {
    debugPrint('Unsupported format: ${image.format.group}, converting to NV21');
    final nv21Bytes = _convertToNV21(image);
    return InputImage.fromBytes(
      bytes: nv21Bytes,
      metadata: InputImageMetadata(
        size: size,
        rotation: rotation,
        format: InputImageFormat.nv21, bytesPerRow: 20,
      ),
    );
  }

  Uint8List _convertToNV21(CameraImage image) {
    final WriteBuffer allBytes = WriteBuffer();

    final yPlane = image.planes[0];
    allBytes.putUint8List(yPlane.bytes);

    if (image.planes.length > 2) {
      final uPlane = image.planes[1];
      final vPlane = image.planes[2];

      for (int i = 0; i < uPlane.bytes.length; i++) {
        allBytes.putUint8(vPlane.bytes[i]);
        allBytes.putUint8(uPlane.bytes[i]);
      }
    }

    return allBytes.done().buffer.asUint8List();
  }

  void _showCameraError(dynamic error) {
    if (!mounted || _disposed) return;

    String errorMessage = 'Camera initialization failed';
    if (error is CameraException) {
      if (error.code == 'CameraAccessDenied') {
        errorMessage = 'Camera permission denied. Please enable camera access in settings.';
      } else {
        errorMessage = error.description ?? errorMessage;
      }
    } else {
      errorMessage = error.toString();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        duration: const Duration(seconds: 5),
      ),
    );

    _cameraReady = false;
    if (mounted) setState(() {});
  }

  InputImageFormat _getInputImageFormat(ImageFormatGroup formatGroup) {
    switch (formatGroup) {
      case ImageFormatGroup.yuv420:
        return InputImageFormat.yuv420;
      case ImageFormatGroup.bgra8888:
        return InputImageFormat.bgra8888;
      case ImageFormatGroup.nv21:
        return InputImageFormat.nv21;
      default:
        return InputImageFormat.nv21;
    }
  }

  Uint8List _convertToJpeg(CameraImage image) {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }

  Uint8List _concatenatePlanes(List<Plane> planes) {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }

  InputImageRotation _rotationIntToInputImageRotation(int rotation) {
    switch (rotation) {
      case 0:
        return InputImageRotation.rotation0deg;
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  void _updateGuidance(CameraImage image, Face? face) {
    if (_disposed) return;

    if (face == null) {
      _instruction = 'Center your face in the oval';
      _complianceProgress = max(_complianceProgress - 0.06, 0.0);
      _consecutiveGoodFrames = 0;
      return;
    }

    final previewW = image.width.toDouble();
    final previewH = image.height.toDouble();
    final rect = face.boundingBox;

    final faceCx = (rect.left + rect.right) / 1.5;
    final faceCy = (rect.top + rect.bottom) / 2.5;
    final cxNorm = (faceCx / previewW) * 2 - 1;
    final cyNorm = (faceCy / previewH) * 2 - 1;
    final faceHeightFrac = rect.height / previewH;

    final double yaw = (face.headEulerAngleY ?? 0).toDouble();
    final double roll = (face.headEulerAngleZ ?? 0).toDouble();
    final double pitch = (face.headEulerAngleX ?? 0).toDouble();

    String? need;
    if (yaw.abs() > kMaxYawDeg) {
      need = yaw > 0 ? 'Turn a bit LEFT' : 'Turn a bit RIGHT';
    } else if (roll.abs() > kMaxRollDeg) {
      need = roll > 0 ? 'Tilt head LEFT' : 'Tilt head RIGHT';
    } else if (pitch.abs() > kMaxPitchDeg) {
      need = pitch > 0 ? 'Lower your chin slightly' : 'Raise your chin slightly';
    } else if (cxNorm.abs() > kCenterTolerance) {
      need = cxNorm > 0 ? 'Move a little RIGHT' : 'Move a little LEFT';
    } else if (cyNorm.abs() > kCenterTolerance) {
      need = cyNorm > 0 ? 'Move a little DOWN' : 'Move a little UP';
    } else if (faceHeightFrac < kMinFaceSize) {
      need = 'Move CLOSER';
    } else if (faceHeightFrac > kMaxFaceSize) {
      need = 'Move FARTHER';
    }

    if (need != null) {
      _instruction = need;
      _complianceProgress = max(_complianceProgress - 0.04, 0.0);
      _consecutiveGoodFrames = 0;
      return;
    }

    _instruction = 'Perfect! Hold still…';
    _complianceProgress = min(_complianceProgress + 0.08, 1.0);
    _consecutiveGoodFrames++;

    if (!_capturing && _consecutiveGoodFrames >= kFramesToAutoCapture) {
      _autoCapture();
    }
  }

  Future<void> _autoCapture() async {
    if (_disposed || _capturing) return;

    _capturing = true;
    _instruction = 'Capturing…';
    if (mounted) setState(() {});

    try {
      await _stopStream();
      await Future.delayed(const Duration(milliseconds: 200));

      if (_disposed || !(_cameraController?.value.isInitialized ?? false)) {
        throw Exception('Camera not ready');
      }

      final XFile shot = await _cameraController!.takePicture();
      File imageFile = File(shot.path);

      if (_latestFace != null) {
        try {
          final cropped = await _cropFaceFromImage(imageFile, _latestFace!);
          if (cropped != null) {
            imageFile = cropped;
          }
        } catch (e) {
          debugPrint("Face cropping failed, using full image: $e");
        }
      }

      await _sendForAnalysis(imageFile);

    } catch (e) {
      debugPrint('Capture error: $e');
      if (mounted && !_disposed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Capture failed: $e')),
        );
      }
      _capturing = false;
      if (!_disposed) {
        await _startStream();
      }
    }
  }

  Future<File?> _cropFaceFromImage(File imageFile, Face face) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final original = img.decodeImage(bytes);
      if (original == null) return null;

      final rect = face.boundingBox;
      int extraHeight = (rect.height * 0.2).toInt();
      int x = rect.left.toInt().clamp(0, original.width - 1);
      int y = rect.top.toInt().clamp(0, original.height - 1);
      int w = rect.width.toInt().clamp(1, original.width - x);
      int h = (rect.height.toInt() + extraHeight).clamp(1, original.height - y);

      final cropped = img.copyCrop(original, x: x, y: y, width: w, height: h);

      final croppedBytes = img.encodeJpg(cropped);
      final croppedFile = File(imageFile.path.replaceAll('.jpg', '_face.jpg'));
      await croppedFile.writeAsBytes(croppedBytes);
      return croppedFile;
    } catch (e) {
      debugPrint("Error cropping face: $e");
      return null;
    }
  }

  Future<void> _sendForAnalysis(File imageFile) async {
    if (_disposed || _me == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile not loaded yet.')),
        );
      }
      _capturing = false;
      if (!_disposed) await _startStream();
      return;
    }

    try {
      await sessionRepository.setImagePath(imageFile.path);
    } catch (e) {
      debugPrint('Failed to save image path: $e');
    }

    final input = SkinAnalysisInput(
      userId: int.tryParse(_me?.id ?? '') ?? 0,
      image: imageFile,
      analysisDate: DateTime.now().toIso8601String(),
    );

    if (mounted && !_disposed) {
      context.read<SkinAnalysisCubit>().analyzeSkin(input);
    }
  }

  void _handleAnalysisResult(SkinAnalysisState state) async {
    if (_disposed) return;

    if (state.status == SkinAnalysisStatus.success) {
      if (mounted) {
        NavRouter.push(context, const SkinHealth1());
      }
    } else if (state.status == SkinAnalysisStatus.failure) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Analysis failed: ${state.errorMessage}')),
        );
        _capturing = false;
        if (!_disposed) await _startStream();
      }
    }
  }

  @override
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_disposed) return;
    final controller = _cameraController;
    if (controller == null) return;

    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _stopStream();
    } else if (state == AppLifecycleState.resumed) {
      if (controller.value.isInitialized) {
        _startStream();
      } else {
        _cameraReady = false;
        _streaming = false;
        _capturing = false;
        if (mounted) setState(() {});
        _initCamera();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);

    _scanAnimController.dispose();

    _stopStream();
    _cameraController?.dispose();

    _faceDetector.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_disposed) return const SizedBox.shrink();

    if (_loadingProfile) {
      return Scaffold(
        backgroundColor: AppColors.white,
        body: const _CenteredLoader(title: 'Loading profile data...'),
      );
    }

    if (_me == null) {
      return Scaffold(
        backgroundColor: AppColors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
               Text(
                'Failed to load profile data',
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              CustomElevatedButton(
                text: 'Retry',
                onPressed: () async {
                  if (!_disposed) {
                    setState(() => _loadingProfile = true);
                    await _loadProfileThenInit();
                  }
                },
                color: const Color(0xffC0F698),
              ),
            ],
          ),
        ),
      );
    }

    return BlocListener<SkinAnalysisCubit, SkinAnalysisState>(
      listener: (context, state) => _handleAnalysisResult(state),
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: SizedBox.expand(
           child : Stack(
              children: [
                Positioned.fill(
                  child: Builder(
                    builder: (context) {
                      debugPrint('Camera ready: $_cameraReady, Controller initialized: ${_cameraController?.value.isInitialized ?? false}');
                      if (_cameraReady && _cameraController != null && _cameraController!.value.isInitialized) {
                        return CameraPreview(_cameraController!);
                      } else {
                        return const _CenteredLoader(title: 'Initializing camera...');
                      }
                    },
                  ),
                ),

                // Overlay
                if (_cameraReady)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _FaceOverlayPainter(
                        progress: _complianceProgress, // <-- use progress here
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black,
                            blurRadius: 16,
                            spreadRadius: 10,
                            offset: const Offset(3, 0),
                          )
                        ]
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _InstructionPill(text: _instruction),
                        const SizedBox(height: 8),
                        if (!_capturing)
                          Text(
                            'Tips: good lighting • remove glasses • keep still',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                      ],
                    ),
                  ),
                ),
                BlocBuilder<SkinAnalysisCubit, SkinAnalysisState>(
                  builder: (context, state) {
                    if (state.status == SkinAnalysisStatus.loading) {
                      return Container(
                        color: Colors.black.withOpacity(0.45),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(color: Color(0xffC0F698)),
                              const SizedBox(height: 16),
                              Text(
                                'Analyzing your skin...',
                                style: GoogleFonts.poppins(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Widget classes remain the same
class _CenteredLoader extends StatelessWidget {
  final String title;
  const _CenteredLoader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Color(0xffC0F698)),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _InstructionPill extends StatelessWidget {
  final String text;
  const _InstructionPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _FaceOverlayPainter extends CustomPainter {
  final double progress;

  _FaceOverlayPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2.1);
    final ovalWidth = size.width * 0.70;
    final ovalHeight = size.height * 0.62;
    final rect = Rect.fromCenter(
      center: center,
      width: ovalWidth,
      height: ovalHeight,
    );
    // Paints
    final basePaint = Paint()
      ..color = AppColors.grey
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.butt;

    final progressPaint = Paint()
      ..color = const Color(0xffC0F698)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.butt;

    _drawDashedBorder(canvas, rect, 1.0, basePaint); // background grey
    if (progress > 0) { // progress > 0
      _drawDashedBorder(canvas, rect, progress, progressPaint);
    }  }

  void _drawDashedBorder(Canvas canvas, Rect rect, double progress, Paint paint) {
    const dashCount = 150; // number of dashes
    final angleStep = (2 * pi) / dashCount;
    final sweep = 2 * pi * progress;

    for (int i = 0; i < dashCount; i++) {
      final angle = -pi / 2 + i * angleStep; // start at top
      if (angle > -pi / 2.4 + sweep) break; // stop at progress

      // Point on ellipse boundary
      final x = rect.center.dx + rect.width / 1.6 * cos(angle);
      final y = rect.center.dy + rect.height / 2.0 * sin(angle);
      final point = Offset(x, y);

      // Dash direction (rotate 45° so it looks like `/`)
      final dashLength = 10.0;
      final dx = cos(angle + pi / 10) * dashLength;
      final dy = sin(angle + pi / 10) * dashLength;

      final p1 = point - Offset(dx / 2, dy / 2);
      final p2 = point + Offset(dx / 2, dy / 2);

      canvas.drawLine(p1, p2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FaceOverlayPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}