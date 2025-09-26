import 'package:Glowzel/module/welcome/pages/welcome_aboard2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../Constant/app_color.dart';
import '../../../ui/button/custom_gradient_button.dart';
import '../../../ui/widget/nav_router.dart';

class DermatologistScreen extends StatefulWidget {
  const DermatologistScreen({super.key});

  @override
  State<DermatologistScreen> createState() => _DermatologistScreenState();
}

class _DermatologistScreenState extends State<DermatologistScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(child: Image.asset('assets/images/png/welcome1'
              '.png', fit: BoxFit.cover)),
          Padding(
            padding: const EdgeInsets.only(left: 10,right: 10,bottom: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => NavRouter.pop(context),
                  icon: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                    ),
                    child:  Image.asset(
                      'assets/images/png/arrow.png',
                    ),
                  ),
                ),
                const Spacer(),
                Center(child: Image.asset('assets/images/png/vector.png')),
                SizedBox(height: 28),
                Text(
                  'Glowzel was developed with the help of expert dermatologists and skincare professionals.',
                  style: GoogleFonts.montserrat(
                    color: AppColors.lightGreen,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 18),
                Text(
                  'Your skincare plan and the content inside of the app are based on decades of research. Let’s start your journey to glowzel  skin!',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                Center(
                  child: CustomGradientButton(text: 'Great!',
                      onPressed: (){
                    NavRouter.push(context, WelcomeAboardScreen2());
                      }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
