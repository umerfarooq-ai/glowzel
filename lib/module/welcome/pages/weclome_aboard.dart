import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../Constant/app_color.dart';
import '../../../ui/button/custom_gradient_button.dart';
import '../../../ui/widget/nav_router.dart';
import 'dermatologists_journey.dart';

class WelcomeAboardScreen extends StatefulWidget {
  const WelcomeAboardScreen({super.key});

  @override
  State<WelcomeAboardScreen> createState() => _WelcomeAboardScreenState();
}

class _WelcomeAboardScreenState extends State<WelcomeAboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(child: Image.asset('assets/images/png/welcome.png', fit: BoxFit.cover)),
          Padding(
            padding: const EdgeInsets.only(left: 10,right: 10,bottom: 40),
            child: Column(
              children: [
                const Spacer(),
                Container(
                  width: 49,
                  height: 49,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check,color: Color(0xff7FAE5C),size: 30),
                ),
                SizedBox(height: 17),
                Text(
                  'Welcome aboard!',
                  style: GoogleFonts.montserrat(
                    color: AppColors.lightGreen,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 11),
                Text(
                  'Your personalized skincare plan is ready!',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                CustomGradientButton(text: 'Get Started',
                    onPressed: (){
                  NavRouter.push(context, DermatologistScreen());
                    }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
