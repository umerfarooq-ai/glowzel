import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:Glowzel/module/Home/widget/drop_down1.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:Glowzel/module/Home/widget/date_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../Constant/app_color.dart';
import '../../../core/exceptions/api_error.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/security/secure_auth_storage.dart';
import '../../../core/storage_services/storage_service.dart';
import '../../Dashboard/cubit/dashboard_cubit.dart';
import '../../authentication/model/auth_response.dart';
import '../../authentication/repository/auth_repository.dart';
import '../../authentication/repository/session_repository.dart';
import '../../scan/model/skin_analysis_response.dart';
import '../../user/models/user_model.dart';
import '../../user/repository/user_account_repository.dart';
import '../widget/circle1_widget.dart';
import '../widget/circle_widget.dart';
import '../widget/skin_progress_summary.dart';
import '../widget/uv_index_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late StorageService storageService;
  late AuthRepository authRepository;
  late SessionRepository sessionRepository;
  late Future<UserModel?> userFuture;
  late Future<SkinAnalysisResponse?> skinHealthFuture;
   String? imagePath;
  String selectedDuration = 'Daily';

  @override
  void initState() {
    super.initState();
    sessionRepository = SessionRepository(
        storageService: GetIt.I<StorageService>(),
        authSecuredStorage: GetIt.I<AuthSecuredStorage>());
    authRepository = AuthRepository(
      dioClient: GetIt.I<DioClient>(),
      authSecuredStorage: GetIt.I<AuthSecuredStorage>(),
      userAccountRepository: GetIt.I<UserAccountRepository>(),
      sessionRepository: GetIt.I<SessionRepository>(),
    );
    userFuture = fetchUserData();
    skinHealthFuture = fetchSkinHealth();
    loadImagePath();
  }

  Future<UserModel?> fetchUserData() async {
    try {
      String? token = await sessionRepository.getToken();

      if (token != null) {
        UserModel user = await authRepository.getMe();
        return user;
      } else {
        throw ApiError(message: 'Token not found');
      }
    } catch (e, stackTrace) {
      log('Error fetching user data: $e\nStackTrace: $stackTrace');
      return null;
    }
  }


  void loadImagePath() async {
    final storedPath = await GetIt.I<SessionRepository>().getImagePath();
    setState(() {
      imagePath = storedPath;
    });
  }

  Future<SkinAnalysisResponse?> fetchSkinHealth() async {
    try {
      final scanId = await sessionRepository.getScanId();
      if (scanId == null || scanId.isEmpty) {
        debugPrint('No scanId found');
        return null;
      }

      final result = await authRepository.getSkinHealth(scanId);
      return result;
    } catch (e) {
      debugPrint('Error fetching skin health: $e');
      return null;
    }
  }

  Future<void> checkLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      print("Location permission granted");
    } else {
      print("Location permission denied");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        else if (snapshot.hasError || snapshot.data == null) {
          return Center(
            child: Text(
              snapshot.hasError
                  ? "Failed to fetch user data"
                  : "No User Data Found",
              style: GoogleFonts.poppins(
                  color: Colors.white),
            ),
          );
        }
        final user = snapshot.data!;
        return FutureBuilder<SkinAnalysisResponse?>(
          future: skinHealthFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            else if (snapshot.hasError || snapshot.data == null) {
              return Center(
                child: Text(
                  snapshot.hasError
                      ? "Failed to fetch user data"
                      : "No User Data Found",
                  style: GoogleFonts.poppins(
                      color: Colors.white),
                ),
              );
            }
            final skinHealthData = snapshot.data!;
            final String? productRecs = skinHealthData.productRecommendations;
            final List<String> recommendedProducts = productRecs != null && productRecs.isNotEmpty
                ? productRecs.split(RegExp(r'[,;\n]')).map((e) => e.trim()).toList()
                : [];
            return Scaffold(
              backgroundColor: AppColors.grey3,
              body: SingleChildScrollView(
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(top:10,left: 16,right: 16,bottom: 50),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: ClipOval(
                                child: user.image != null && user.image!.isNotEmpty
                                    ? (user.image!.startsWith('http') || user.image!.startsWith('https')
                                    ? Image.network(
                                  user.image!,
                                  fit: BoxFit.cover,
                                  width: 40,
                                  height: 40,
                                )
                                    : Image(
                                  image: MemoryImage(
                                    base64Decode(user.image!),
                                  ),
                                  fit: BoxFit.cover,
                                  width: 40,
                                  height: 40,
                                ))
                                    : Image.asset(
                                  'assets/images/png/women4.png',
                                  fit: BoxFit.cover,
                                  width: 40,
                                  height: 40,
                                ),
                              ),
                            ),
                            SizedBox(width: 9),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text('Hi! ${user.firstname} ${user.lastname}',
                                        style: GoogleFonts.poppins(
                                            color: AppColors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400)),
                                    SizedBox(width: 84),
                                    CustomDropdown(
                                      initialValue: selectedDuration,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedDuration = value;
                                        });
                                      }, options: ['Daily', 'Weekly', 'Monthly'],
                                    ),
                                  ],
                                ),
                                Text('Transform your skin health',
                                    style: GoogleFonts.poppins(
                                        color: AppColors.black,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w400)),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 36),
                        SkinProgressSummary(selectedDuration:selectedDuration),
                        SizedBox(height: 52),
                        UVIndexCard(),
                        SizedBox(height: 26),
                        Text('Recommend for you',
                          style: GoogleFonts.montserrat(
                          color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 22),
                        Column(
                          children: [
                            Row(
                              children: [
                                Expanded(child: RecommendedProductWidget(image: 'assets/images/png/rp1.png', text: recommendedProducts.length > 0 ? recommendedProducts[0] : '',
                                )),
                                SizedBox(width: 10),
                                Expanded(child: RecommendedProductWidget(image: 'assets/images/png/rp2.png', text: recommendedProducts.length > 1 ? recommendedProducts[1] : '',
                                )),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(child: RecommendedProductWidget(image: 'assets/images/png/rp3.png', text: recommendedProducts.length > 2 ? recommendedProducts[2] : '',
                                )),
                                SizedBox(width: 10),
                                Expanded(child: RecommendedProductWidget(image: 'assets/images/png/rp4.png', text: recommendedProducts.length > 3 ? recommendedProducts[3] : '',
                                )),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class CustomListTile extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;

  const CustomListTile({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 162,
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 1),
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.25),
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.asset(
            imagePath,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.montserrat(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RecommendedProductWidget extends StatelessWidget
{
  final String image;
  final String text;

  const RecommendedProductWidget({
    Key? key,
    required this.image,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLocalFile = image.startsWith('/data') || image.startsWith('/storage');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 160,
          height: 183,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: isLocalFile
                ? Image.file(File(image), fit: BoxFit.cover)
                : Image.asset(image, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          text,
          style: GoogleFonts.montserrat(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
           maxLines: 1,
        ),
        const SizedBox(height: 2),
         Text(
          'Vitamin boost mask',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 10,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }
}



