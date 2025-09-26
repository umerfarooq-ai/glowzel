import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:Glowzel/ui/widget/nav_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Constant/app_color.dart';
import '../../core/network/dio_client.dart';
import '../../core/security/secure_auth_storage.dart';
import '../../core/storage_services/storage_service.dart';
import '../../ui/button/custom_elevated_button.dart';
import '../authentication/repository/auth_repository.dart';
import '../authentication/repository/session_repository.dart';
import '../notification/widget/notification-toggle.dart';
import '../scan/model/skin_analysis_response.dart';
import '../user/repository/user_account_repository.dart';

class EditStepsMorningPage extends StatefulWidget {
  final List<bool> initialToggles;
  final DateTime selectedDate;
  const EditStepsMorningPage({super.key, required this.initialToggles, required this.selectedDate});

  @override
  State<EditStepsMorningPage> createState() => _EditStepsMorningPageState();
}

class _EditStepsMorningPageState extends State<EditStepsMorningPage> {
  late List<bool> stepsToggles;
  List<Map<String, dynamic>> steps = [];
  late List<Map<String, dynamic>> apiSteps = [];
  late AuthRepository authRepository;
  late SessionRepository sessionRepository;
  late Future<SkinAnalysisResponse?> skinHealthFuture;

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
    loadToggles();
    skinHealthFuture = fetchSkinHealthForDate(widget.selectedDate);
  }

  void loadToggles() async {
    final saved = await sessionRepository.getMorningToggleForDate(widget.selectedDate);
    List<bool> loadedToggles;

    if (saved != null && saved.isNotEmpty) {
      loadedToggles = saved;
    } else {
      loadedToggles = List.from(widget.initialToggles);
      if (loadedToggles.length < 9) {
        loadedToggles.addAll(List.generate(9 - loadedToggles.length, (_) => false));
      }
    }

    setState(() {
      stepsToggles = loadedToggles;
    });
  }


  Future<SkinAnalysisResponse?> fetchSkinHealthForDate(DateTime date) async {
    try {
      final userId = await sessionRepository.getId();
      if (userId == null) throw Exception("User ID is null");

      final response = await GetIt.I<DioClient>().get(
        '/api/skin-analysis/user/$userId/history',
        queryParameters: {
          'limit': 50,
          'skip': 0,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        final analyses = List<Map<String, dynamic>>.from(
          jsonData['data']['analyses'] ?? [],
        );

        final String targetDate = DateFormat("yyyy-MM-dd").format(date);
        final analysis = analyses.firstWhere(
              (a) {
            final analysisDate = (a['analysisDate'] ?? '').toString();
            return analysisDate.startsWith(targetDate);
          },
          orElse: () => {},
        );

        if (analysis.isEmpty) {
          debugPrint("❌ No analysis found for $targetDate");
          return null;
        }

        final scanId = analysis['scanId'];
        if (scanId == null) return null;

        final result = await authRepository.getSkinHealth(scanId);

        if (result != null) {
          steps = (result.amRoutine as List<dynamic>? ?? [])
              .map<Map<String, dynamic>>((step) => {
            'title': '${step['product_type']}',
            'description': step['description'] ?? '',
            'isCustom': false,
          })
              .toList();
        }
        return result;
      } else {
        throw Exception("Failed to fetch history");
      }
    } catch (e) {
      debugPrint("Error fetching skin health for date: $e");
      return null;
    }
  }

  void saveRoutineToggles() async {
    final encoded = jsonEncode(stepsToggles);
    await sessionRepository.setMorningToggleForDate(widget.selectedDate, stepsToggles);
  }

  void _showAddProductDialog() {
    String productName = '';
    String productDescription = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('Add Your Product'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Product Name'),
                onChanged: (value) => productName = value,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Description'),
                onChanged: (value) => productDescription = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel', style: GoogleFonts.poppins(
                  color: Colors.black),),
              onPressed: () => Navigator.pop(context),
            ),
            SizedBox(
              width: 100,
              child: CustomElevatedButton(text: 'Add', onPressed: () async {
                setState(() {
                  steps.add({
                    'title': productName,
                    'description': productDescription,
                    'isCustom': true,
                  });
                });
                Navigator.pop(context);
              },),
            )
          ],
        );
      },
    );
  }

  final defaultImages = [
    'assets/images/png/p1.png',
    'assets/images/png/p2.png',
    'assets/images/png/p3.png',
    'assets/images/png/p5.png',
  ];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SkinAnalysisResponse?>(
      future: skinHealthFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || snapshot.data == null) {
          return Center(
            child: Text(
              snapshot.hasError
                  ? "Failed to fetch user data"
                  : "No User Data Found",
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          );
        }

        final skinHealthData = snapshot.data!;

        // Load API steps only once
        if (steps.isEmpty) {
          final apiSteps = (skinHealthData.amRoutine as List<dynamic>?)
              ?.map<Map<String, dynamic>>((step) => {
            "stepNumber": step['step_number'],
            'title': '${step['product_type']}',
            'description': step['description'] ?? '',
            'isCustom': false,
            'image': step['image'] ?? 'assets/images/png/p1.png',
          })
              .toList() ??
              [];
          steps.addAll(apiSteps);
        }

        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
           return Container(
              width: 393,
              height: 610,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          NavRouter.pop(context, stepsToggles);
                        },
                        child: SvgPicture.asset('assets/images/svg/arrow3.svg'),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Edit steps',
                        style: GoogleFonts.poppins(
                          color: AppColors.black,
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Add or remove product from the routine',
                        style: GoogleFonts.poppins(
                          color: AppColors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 28),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: steps.length,
                        separatorBuilder: (_, __) => Column(
                          children: [
                            const SizedBox(height: 20),
                            Divider(color: AppColors.grey2),
                            const SizedBox(height: 20),
                          ],
                        ),
                        itemBuilder: (context, i) {
                          final step = steps[i];
                          return buildRoutineItem(
                            index: i,
                            stepNumber: step['step_number'] ?? (i + 1),
                            title: step['title'],
                            imagePath: step['image'] ?? defaultImages[i % defaultImages.length],
                            onAddProductTap: _showAddProductDialog,
                            backgroundColor: Colors.white,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
  Widget buildRoutineItem({
    required int stepNumber,
    required String title,
    required String imagePath,
    String? description,
    VoidCallback? onTapNavigate,
    VoidCallback? onAddProductTap,
    bool isBlack = false,
    Color backgroundColor = const Color(0xffFFF0FA),
    Gradient? backgroundGradient,
    Color outerColor = Colors.black,
    required int index,
  }) {
    final isSelected = stepsToggles[index];

    return GestureDetector(
      onTap: () {
        setState(() {
          stepsToggles[index] = !stepsToggles[index];
        });
        saveRoutineToggles();
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected? Color(0xffFF2009):AppColors.lightGreen,
              shape: BoxShape.circle,
            ),
            child: Container(
              width: 12,
              color: isSelected? Colors.white:AppColors.lightGreen,
              height: 1,
            ),
          ),
          const SizedBox(width: 20),
          Text(
            "$stepNumber",
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              width: 59,
              height: 64,
              decoration: BoxDecoration(
                color: backgroundGradient == null ? backgroundColor : null,
                gradient: backgroundGradient,
                borderRadius: BorderRadius.circular(6),
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (description != null && description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      color: Colors.grey[700],
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: onAddProductTap,
                  child: Container(
                    width: 130,
                    height: 21,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xffDBEAAC),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '+ Add your own product',
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}