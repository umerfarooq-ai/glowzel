import 'dart:async';

import 'package:Glowzel/ui/widget/nav_router.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../Constant/app_color.dart';
import '../../Dashboard/pages/dashboard_page.dart';
import '../widget/timer_widget.dart';

class StartTreatmentPage4 extends StatefulWidget {

  const StartTreatmentPage4({super.key});

  @override
  State<StartTreatmentPage4> createState() => _StartTreatmentPage4State();
}

class _StartTreatmentPage4State extends State<StartTreatmentPage4> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(top: 40, left: 14, right: 14),
        child: SingleChildScrollView(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(onPressed: () {
                  NavRouter.pushAndRemoveUntil(context, DashboardPage(userId: 'userId',initialPage: 4));
                }, icon: Text(
                  'Close',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                    color: Colors.black,
                  ),
                ),),
                SizedBox(height: 11),
                Center(
                  child: Text(
                    'Vitamin Boost Mask',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 42),
                Center(
                  child: Text(
                    'Keep the mask on for 15 minutes',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 80),
                Center(child: TimerWidget()),
              ]
          ),
        ),
      ),
    );
  }
}




