import 'dart:convert';

import 'package:Glowzel/ui/widget/nav_router.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Constant/app_color.dart';
import '../../core/security/secure_auth_storage.dart';
import '../../core/storage_services/storage_service.dart';
import '../authentication/repository/session_repository.dart';
import '../notification/widget/notification-toggle.dart';

class EditRoutinePage extends StatefulWidget {
  final List<bool> initialToggles;
  const EditRoutinePage({super.key, required this.initialToggles});

  @override
  State<EditRoutinePage> createState() => _EditRoutinePageState();
}

class _EditRoutinePageState extends State<EditRoutinePage> {
  late List<bool> routineToggles;
  late SessionRepository sessionRepository;

  @override
  void initState() {
    super.initState();
    sessionRepository = SessionRepository(
        storageService: GetIt.I<StorageService>(),
        authSecuredStorage: GetIt.I<AuthSecuredStorage>());
    routineToggles = List.from(widget.initialToggles);
    if (routineToggles.isEmpty) {
      routineToggles = [
        true,
        false,
        true,
        true,
        false,
        false,
        false,
        false,
        false,
      ];
    }
    else {
      routineToggles = List.from(widget.initialToggles);
      if (routineToggles.length < 9) {
        routineToggles.addAll(List.generate(9 - routineToggles.length, (_) => false));
      }
    }
  }
  void saveRoutineToggles() async {
    final encoded = jsonEncode(routineToggles);
    await sessionRepository.setToggle(encoded);
  }


  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
      return Container(
        width: 393,
        height: 610,
        decoration: BoxDecoration(
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
                onTap: (){
                  NavRouter.pop(context,routineToggles);
                },
                  child:Container(
                      child: SvgPicture.asset('assets/images/svg/arrow3.svg'))),
                SizedBox(height: 14),
                Text('Routines',
                    style: GoogleFonts.poppins(
                        color: AppColors.black,
                        fontSize: 25,
                        fontWeight: FontWeight.w600)),
                SizedBox(height: 6),
                Text('Customize your routines to align with your specific needs and schedule.',
                    style: GoogleFonts.poppins(
                        color: AppColors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w400)),
                SizedBox(height: 22),
                Text('ESSENTIALS',
                    style: GoogleFonts.poppins(
                        color: AppColors.black.withOpacity(0.72),
                        fontSize: 12,
                        fontWeight: FontWeight.w400)),
                SizedBox(height: 28),
                buildRoutineItem(0, 'Morning routine', 'Daily', 'assets/images/svg/morning.svg'),
                SizedBox(height: 18),
                buildRoutineItem(1, 'Afternoon routine', 'Daily', 'assets/images/svg/afternoon.svg',isBlack: true,
                    outerColor: Color(0xff4779C3)),
                SizedBox(height: 18),
                buildRoutineItem(2, 'Skin daily log', 'Daily', 'assets/images/svg/scan3.svg'),
                SizedBox(height: 18),
                buildRoutineItem(3, 'Evening routine', 'Daily', 'assets/images/svg/moon.svg',isBlack: true),
                SizedBox(height: 18),
                buildRoutineItem(4, 'Night routine', 'Daily', 'assets/images/svg/night.svg',isBlack: true,
                  backgroundColor: Color(0xffF4F4F4),
                ),
                SizedBox(height: 28),
                Text('GET RID OF THE EXTRAS',
                    style: GoogleFonts.poppins(
                        color: AppColors.black.withOpacity(0.72),
                        fontSize: 12,
                        fontWeight: FontWeight.w400)),
                SizedBox(height: 28),
                buildRoutineItem(5, 'Face exfoliation', 'Every 10 days', 'assets/images/svg/face.svg',
                backgroundGradient: LinearGradient(
                  colors: [
                    Color(0xffE2F5FF),
                    Color(0xff7FC4E9),
                  ],
                ),),
                SizedBox(height: 18),
                buildRoutineItem(6, 'Body exfoliation', 'Every sunday', 'assets/images/svg/body.svg',
                  backgroundGradient: LinearGradient(
                    colors: [
                      Color(0xffFFF0FA),
                      Color(0xff3F2938),
                    ],
                  ),),
                SizedBox(height: 18),
                buildRoutineItem(7, 'Face mask', 'Daily', 'assets/images/svg/mask.svg'),
                SizedBox(height: 18),
                buildRoutineItem(8, 'Under eye mask', 'Daily', 'assets/images/svg/mask1.svg',
                backgroundColor: Color(0xff00A8B5),
                ),
              ],
            ),
          ),
        ),
      );
      },
    );
  }
  Widget buildRoutineItem(
      int index,
      String title,
      String subtitle,
      String imagePath, {
        bool isBlack = false,
        VoidCallback? onTapNavigate,
        Color backgroundColor = const Color(0xffFFF0FA),
        Gradient? backgroundGradient,
        Color outerColor =  Colors.black,
      }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: backgroundGradient == null ? backgroundColor ?? const Color(0xffFFF0FA) : null,
            gradient: backgroundGradient,
            shape: BoxShape.circle,
          ),
          child: isBlack
              ? Container(
            margin: const EdgeInsets.all(10),
            decoration:  BoxDecoration(
              color: outerColor,
              shape: BoxShape.circle,
            ),
            child: ClipOval(child: Center(child: SvgPicture.asset(imagePath))),
          )
              : ClipOval(child: Center(child: SvgPicture.asset(imagePath))),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500),
            ),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w300),
            ),
          ],
        ),
        Spacer(),
        NotificationToggle(
          isEnabled:  routineToggles[index],
          onToggle: (value) {
            setState(() {
              routineToggles[index] = value;
            });
            saveRoutineToggles();
          },
        ),
      ],
    );
  }
}
