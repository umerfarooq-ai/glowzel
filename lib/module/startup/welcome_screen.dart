import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

import '../../Constant/app_color.dart';
import '../../ui/button/custom_elevated_button.dart';
import '../../ui/widget/nav_router.dart';
import '../authentication/pages/login_page.dart';
import '../authentication/pages/signup_page.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset("assets/videos/wc.mp4")
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        _controller.setLooping(true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.4),
          ),
          Padding(
            padding: EdgeInsets.only(top: 50,bottom: 10),
            child: Column(
              children: [
                SvgPicture.asset('assets/images/svg/wc_logo.svg'),
                SizedBox(height: 18),
                Text('Your Glow, your way',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.white,
                    )),
                Spacer(),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.white.withOpacity(0.62),
                    ),
                    children: [
                      TextSpan(text: 'By continuing, you agree to our\n',
                      ),
                      TextSpan(
                        text: 'Terms',
                      ),
                      TextSpan(text: ' and ',
                      ),
                      TextSpan(
                        text: 'Privacy policy',
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: 266,
                  child: CustomElevatedButton(text: 'GET STARTED',
                      onPressed: (){
                    NavRouter.push(context, SignupPage());
                      }),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account ?',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.white,
                        )),
                    IconButton(onPressed: (){
                      NavRouter.push(context, LoginPage());
                    }, icon:Text('Login',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.lightGreen,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.lightGreen,
                        ))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
