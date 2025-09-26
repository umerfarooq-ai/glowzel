import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:Glowzel/module/diary/morning_routine_page.dart';
import 'package:Glowzel/ui/button/custom_elevated_button.dart';
import 'package:Glowzel/ui/widget/nav_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../Constant/app_color.dart';
import '../../core/security/secure_auth_storage.dart';
import '../../core/storage_services/storage_service.dart';
import '../Dashboard/pages/dashboard_page.dart';
import '../authentication/repository/session_repository.dart';
import 'diary_page.dart';

class PersonalizedRoutineScreen extends StatefulWidget {
  const PersonalizedRoutineScreen({super.key});

  @override
  State<PersonalizedRoutineScreen> createState() => _PersonalizedRoutineScreenState();
}

class _PersonalizedRoutineScreenState extends State<PersonalizedRoutineScreen> {
  late SessionRepository sessionRepository;

  void initState() {
    super.initState();
    sessionRepository = SessionRepository(
        storageService: GetIt.I<StorageService>(),
        authSecuredStorage: GetIt.I<AuthSecuredStorage>());
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 384,
                child: Image.asset('assets/images/png/personalize.png',fit:BoxFit.cover)),
            Padding(
              padding: const EdgeInsets.only(top: 26,bottom: 20,left: 29,right: 28),
              child: Column(
                children: [
                  Text(
                    'Welcome to your personalized Routines!',
                    style: GoogleFonts.montserrat(
                        color: Colors.black, fontSize: 24, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 18),
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      children: [
                        const TextSpan(
                          text: 'You deserve a skincare routine that truly works for you. ',
                        ),
                        TextSpan(
                          text: 'Glowzel',
                          style: GoogleFonts.poppins(
                            color: AppColors.lightGreen2,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const TextSpan(
                          text: ' has crafted a custom regimen tailored specifically to your skin profile and lifestyle.',
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'You’ll follow a routine where every step is meaningful. From cleansing to hydration,\ndesigned to keep your skin balanced, glowing, and protected every single day.',
                    style: GoogleFonts.poppins(
                        color: Colors.black, fontSize: 14, fontWeight: FontWeight.w400),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'It’s more than a routine, it’s a journey toward your best skin.',
                    style: GoogleFonts.poppins(
                        color: Colors.black, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 25),
                ],
              ),
            ),

          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 37, right: 37, bottom: 20),
        child:CustomElevatedButton(text: 'START MY GLOW', onPressed: () async{
          final userId = await sessionRepository.getId();
          print('user id is ${userId}');
          NavRouter.push(context, DashboardPage(userId: userId!,initialPage: 3));
        }),

      ),

    );
  }
}
