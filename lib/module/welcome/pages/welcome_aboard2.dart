import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


import '../../../Constant/app_color.dart';
import '../../../ui/button/custom_gradient_button.dart';
import '../../../ui/widget/nav_router.dart';
import 'essential_routine_page.dart';

class WelcomeAboardScreen2 extends StatefulWidget {
  const WelcomeAboardScreen2({super.key});

  @override
  State<WelcomeAboardScreen2> createState() => _WelcomeAboardScreen2State();
}

class _WelcomeAboardScreen2State extends State<WelcomeAboardScreen2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(child: Image.asset('assets/images/png/welcome.png', fit: BoxFit.cover)),
          Padding(
            padding: const EdgeInsets.all(16),
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
                SizedBox(height: 28),
                Text(
                  'This is how we’re going to create perfect skincare for you',
                  style: GoogleFonts.montserrat(
                    color: AppColors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 17),
                Center(
                  child: Text(
                    'You can read these in detail once you’re in the app.',
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
                SizedBox(height: 33),
                CustomListTile(imagePath: 'assets/images/png/routine.png',
                  title: 'Personalized skincare routine',
                  subtitle: 'Based on your skin characteristics and concerns\nwe’ve created a perfect routine steps for you.',),
                SizedBox(height: 20),
                CustomListTile(imagePath: 'assets/images/png/skin_type.png',
                  title: 'Skin type',
                  subtitle: 'Based on your skin characteristics and concerns\nwe’ve created a perfect routine steps for you.',),
                SizedBox(height: 20),
                CustomListTile(imagePath: 'assets/images/png/ingredients.png',
                  title: 'Ingredients',
                  subtitle: 'We have found 18 active ingredients that have\nhigh chance to fix your concerns.',),
                SizedBox(height: 20),
                CustomListTile(imagePath: 'assets/images/png/practise.png',
                  title: 'Best practices',
                  subtitle: 'We’re created a list of best practices to\nreduce your skin problems and concerns.',),
                SizedBox(height: 20),
                CustomListTile(imagePath: 'assets/images/png/diary.png',
                  title: 'Diary',
                  subtitle: 'We’re opened the first page of your diary.\nNow you’ll be able to log your skin progress.',),
                const Spacer(),
                Center(
                  child: CustomGradientButton(text: 'Let’s get started!',
                      onPressed: (){
                    NavRouter.push(context, EssentialRoutineScreen());
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
      width: 361,
      height: 73,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 1),
        borderRadius: BorderRadius.circular(17),
        color: Colors.white,
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
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 10,
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

