import 'dart:developer';
import 'dart:io';
import 'package:Glowzel/ui/widget/nav_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/exceptions/api_error.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/security/secure_auth_storage.dart';
import '../../../core/storage_services/storage_service.dart';
import '../../authentication/repository/auth_repository.dart';
import '../../authentication/repository/session_repository.dart';
import '../../scan/model/skin_analysis_response.dart';
import '../../user/repository/user_account_repository.dart';
import '../pages/vitamin_boost_mask_page.dart';

class TreatmentTabWidget extends StatefulWidget {
  const TreatmentTabWidget({super.key});

  @override
  State<TreatmentTabWidget> createState() => _TreatmentTabWidgetState();
}

class _TreatmentTabWidgetState extends State<TreatmentTabWidget> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late AuthRepository authRepository;
  late SessionRepository sessionRepository;
  late Future<SkinAnalysisResponse?> skinHealthFuture;
  String? imagePath;

  final List<String> tabTitles = [
    'All',
    'Face',
    'Hair',
    'Feet',
    'Nails',
    'Lips',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabTitles.length, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: tabTitles.length,
            itemBuilder: (context, index) {
              final bool isSelected = _tabController.index == index;
              return GestureDetector(
                onTap: () {
                  _tabController.index = index;
                  setState(() {});
                },
                child: Container(
                  width: 61,
                  height: 33,
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                      color: isSelected ? Color(0xffE3F7D4) : Color(0xffF4F4F4),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                            blurRadius: 2,
                            offset: Offset(0, 2),
                            spreadRadius: 0,
                            color: Colors.black.withOpacity(0.25)
                        ),
                      ]
                  ),
                  child: Center(
                    child: Text(
                      tabTitles[index],
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 26),
        SizedBox(
          height: 500,
          child: TabBarView(
            controller: _tabController,
            children: List.generate(tabTitles.length, (tabIndex) {
              return Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TreatmentWidget(
                            image: imagePath ?? 'assets/images/png/girl3.png',
                            text:'Moisturizing',
                            subText: 'Vitamin Boost Mask',
                            timer: '15min',
                            isLocked: false,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TreatmentWidget(
                            image: imagePath ?? 'assets/images/png/girl2.png',
                            text:'Cellulite Reducing',
                            subText: 'Aloe Vera Infused',
                            timer: '15min',
                            isLocked: true,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: TreatmentWidget(
                            image: imagePath ?? 'assets/images/png/girl3.png',
                            text: 'Moisturizing',
                            subText: 'Vitamin Boost Mask',
                            timer: '15min',
                            isLocked: true,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TreatmentWidget(
                            image: imagePath ?? 'assets/images/png/girl5.png',
                            text: 'Hydrating Boost',
                            subText: 'Aloe Vera Infused',
                            timer: '15min',
                            isLocked: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class TreatmentWidget extends StatelessWidget {
  final String image;
  final String text;
  final String subText;
  final String timer;
  final bool isLocked;

  const TreatmentWidget({
    super.key,
    required this.image,
    required this.text,
    required this.subText,
    required this.timer,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    // Check if the image is a local file path
    final isLocalFile = image.startsWith('/data') || image.startsWith('/storage');

    Widget imageContent = Stack(
      children: [
        Container(
          width: 169,
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
        if (isLocked)
          Positioned(
            top: 15,
            right: 18,
            child: Container(
              width: 32,
              height: 27,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.black.withOpacity(0.63),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: SvgPicture.asset('assets/images/svg/lock.svg'),
              ),
            ),
          ),
        Positioned(
          bottom: 13,
          left: 4,
          child: Container(
            width: 70,
            height: 27,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.black.withOpacity(0.63),
            ),
            child: Row(
              children: [
                SvgPicture.asset('assets/images/svg/timer3.svg'),
                const SizedBox(width: 5),
                Text(
                  timer,
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isLocked
            ? imageContent
            : GestureDetector(
          onTap: () {
            NavRouter.push(context, VitaminBoostMaskPage());
          },
          child: imageContent,
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
          subText,
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