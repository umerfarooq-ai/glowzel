import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:Glowzel/module/Dashboard/pages/dashboard_page.dart';
import 'package:Glowzel/module/diary/personalized_routine.dart';
import 'package:Glowzel/module/scan/widget/skin_circle.dart';
import 'package:Glowzel/module/treatment/pages/treatment_page.dart';
import 'package:Glowzel/module/welcome/pages/scan_face.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

import '../../../Constant/app_color.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/security/secure_auth_storage.dart';
import '../../../core/storage_services/storage_service.dart';
import '../../../ui/button/custom_elevated_button.dart';
import '../../../ui/widget/nav_router.dart';
import '../../authentication/repository/auth_repository.dart';
import '../../authentication/repository/session_repository.dart';
import '../../scan/model/skin_analysis_response.dart';
import '../../user/repository/user_account_repository.dart';

class SkinHealth extends StatefulWidget {
  const SkinHealth({super.key});

  @override
  State<SkinHealth> createState() => _SkinHealthState();
}

class _SkinHealthState extends State<SkinHealth> {
  late StorageService storageService;
  late AuthRepository authRepository;
  late SessionRepository sessionRepository;
  late Future<SkinAnalysisResponse?> skinHealthFuture;
  String? imagePath;

  @override
  void initState() {
    super.initState();
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
    skinHealthFuture = fetchSkinHealth();
    loadImagePath();
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return FutureBuilder<SkinAnalysisResponse?>(
      future: skinHealthFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || snapshot.data == null) {
          return Center(
            child: Text(
              snapshot.hasError ? "Failed to fetch user data" : "No User Data Found",
              style: GoogleFonts.poppins(color: Colors.black),
            ),
          );
        }
        final skinHealthData = snapshot.data!;
        final Map<String, num> matrix = skinHealthData.skinHealthMatrix;


        return Scaffold(
          backgroundColor: AppColors.grey3,
          body: Stack(
            children: [
              SizedBox(
                height: 438,
                child: imagePath != null
                    ? Image.file(File(imagePath!), fit: BoxFit.cover)
                    : Image.asset('assets/images/png/women3.png', fit: BoxFit.cover),
              ),
              Positioned(
                top: 60,
                left: 80,
                child: Row(
                  children: [
                    Container(
                      width: 63,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Column(
                        children: [
                          Text('${(skinHealthData.skinHealthMatrix['texture'] ?? 0).toStringAsFixed(0)}%',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                color: AppColors.black,
                              )),
                          Text('Texture',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w300,
                                color: AppColors.black,
                              )),
                        ],
                      ),
                    ),
                    SizedBox(width: 6),
                    DottedBorder(
                      color: Colors.white,
                      strokeWidth: 1.5,
                      dashPattern: [3, 3],
                      borderType: BorderType.Circle,
                      child: Container(
                        height: 24,
                        width: 24,
                        alignment: Alignment.center,
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 190,
                left: 30,
                child: Row(
                  children: [
                    Container(
                      width: 63,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Column(
                        children: [
                          Text('${(skinHealthData.skinHealthMatrix['moisture'] ?? 0).toStringAsFixed(0)}%',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                color: AppColors.black,
                              )),
                          Text('Moisture',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w300,
                                color: AppColors.black,
                              )),
                        ],
                      ),
                    ),
                    SizedBox(width: 6),
                    DottedBorder(
                      color: Colors.white,
                      strokeWidth: 1.5,
                      dashPattern: [3, 3],
                      borderType: BorderType.Circle,
                      child: Container(
                        height: 24,
                        width: 24,
                        alignment: Alignment.center,
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 200,
                left: 240,
                child: Row(
                  children: [
                    DottedBorder(
                      color: Colors.white,
                      strokeWidth: 1.5,
                      dashPattern: [3, 3],
                      borderType: BorderType.Circle,
                      child: Container(
                        height: 24,
                        width: 24,
                        alignment: Alignment.center,
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 6),
                    Container(
                      width: 63,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Column(
                        children: [
                          Text('${(skinHealthData.skinHealthMatrix['elasticity'] ?? 0).toStringAsFixed(0)}%',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                color: AppColors.black,
                              )),
                          Text('Elasticity',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w300,
                                color: AppColors.black,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              DraggableScrollableSheet(
                initialChildSize: 0.45,
                minChildSize: 0.45,
                maxChildSize: 0.7,
                builder: (context, scrollController) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: AppColors.grey3,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                      ),
                    ),
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                            decoration: const BoxDecoration(
                              color: AppColors.lightGreen,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(25),
                                topRight: Radius.circular(25),
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                          "${(skinHealthData.skinHealthMatrix['complexion'] ?? 0).toStringAsFixed(0)}%",
                                          style: GoogleFonts.poppins(
                                            fontSize: 32,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.black,
                                          ),
                                        ),
                                        Text("Skin Health",
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w300,
                                              color: AppColors.black,
                                            )),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          "${(skinHealthData.skinHealthMatrix['moisture'] ?? 0).toStringAsFixed(0)}%",
                                          style: GoogleFonts.poppins(
                                            fontSize: 32,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.black,
                                          ),
                                        ),
                                        Text("Moisture",
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w300,
                                              color: AppColors.black,
                                            )),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  width: 125,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                    color: AppColors.white,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Skin Age ${(skinHealthData.skinHealthMatrix['skin_age'] ?? 0).toInt()}",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w300,
                                      color: AppColors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          Container(
                            width: 50,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Report',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.black,
                                    )),
                                const SizedBox(height: 20),
                                Container(
                                  width: 361,
                                  height: 171,
                                  padding: const EdgeInsets.only(left: 16, top: 8,right: 16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                    color: Colors.white,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            width: 42,
                                            height: 42,
                                            decoration: BoxDecoration(
                                              color: AppColors.lightGreen,
                                              shape: BoxShape.circle,
                                            ),
                                            child: SvgPicture.asset('assets/images/svg/texture.svg',fit: BoxFit.scaleDown),
                                          ),
                                          Text("Texture",
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w300,
                                              )),
                                          Container(
                                            width: 109,
                                            height: 23,
                                            decoration: BoxDecoration(
                                              color: AppColors.lightGreen2,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Center(
                                              child: Text("Intermediate",
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.white,
                                                  )),
                                            ),
                                          ),
                                          SkinCircleScoreWidget(
                                              fontSize: 16,fontWeight: FontWeight.w500,
                                              width: 62, height: 62,
                                              score: matrix['texture'] ?? 0),

                                        ],
                                      ),
                                      SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Acne',
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: AppColors.black,
                                              )),
                                          Text('Dryness',
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: AppColors.black,
                                              )),
                                          Text('Elasticity',
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: AppColors.black,
                                              )),
                                        ],
                                      ),
                                      SizedBox(height: 18),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          SkinCircleScoreWidget(
                                              fontSize: 12,fontWeight: FontWeight.w500,
                                              width: 42, height: 42,
                                              score: matrix['acne'] ?? 0),
                                          SkinCircleScoreWidget(
                                              fontSize: 12,fontWeight: FontWeight.w500,
                                              width: 42, height: 42,
                                              score: matrix['dryness'] ?? 0),
                                          SkinCircleScoreWidget(
                                              fontSize: 12,fontWeight: FontWeight.w500,
                                              width: 42, height: 42,
                                              score: matrix['elasticity'] ?? 0),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 60),
                                Row(
                                  children: [
                                    Expanded(
                                      child: IconButton(
                                        onPressed: (){
                                          NavRouter.push(context, ScanFace());
                                        },
                                        icon: Container(
                                          width: 173,
                                          height: 56,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(30),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.25),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ]
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: 40,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                    color: AppColors.black,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: SvgPicture.asset('assets/images/svg/rescan.svg',fit: BoxFit.scaleDown),
                                                ),
                                                SizedBox(width: 10),
                                                Text("RESCAN",
                                                    style: GoogleFonts.poppins(
                                                      color:Colors.black,
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.w600,
                                                    )),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: SizedBox(
                                        width: 173,
                                        height: 56,
                                        child: CustomElevatedButton(text: 'Continue', onPressed:(){
                                         NavRouter.push(context, PersonalizedRoutineScreen());
                                        }),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
