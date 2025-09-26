import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../Constant/app_color.dart';
import '../../../ui/button/custom_gradient_button.dart';
import '../../../ui/widget/nav_router.dart';
import '../widgets/notification_dialog.dart';

class EssentialRoutineScreen extends StatefulWidget {
  const EssentialRoutineScreen({super.key});

  @override
  State<EssentialRoutineScreen> createState() => _EssentialRoutineScreenState();
}

class _EssentialRoutineScreenState extends State<EssentialRoutineScreen> {
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
                Center(
                  child: Text(
                    'Pick a daily time for your\nessential routines',
                    style: GoogleFonts.montserrat(
                      color: AppColors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 17),
                Center(
                  child: Text(
                    'Let’s start with these essential skincare routines.\nYou can add more  routines in The app later.',
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
                SizedBox(height: 33),
                CustomListTile(
                  imagePath: 'assets/images/png/sun.png',
                  title: 'Morning routine',
                  subtitle: '8 steps', text: '9:00 AM',),
                SizedBox(height: 20),
                CustomListTile(imagePath: 'assets/images/png/scan1.png',
                  title: 'Skin daily log',
                  subtitle: 'Takes less than a minute', text: '10:00 AM',),
                SizedBox(height: 20),
                CustomListTile(imagePath: 'assets/images/png/moon.png',
                  title: 'Evening routine',
                  showBlackInnerBox: true,
                  subtitle: '8 steps',
                text: '8:00 AM',
                ),
                SizedBox(height: 26),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomContainer(imagePath: 'assets/images/png/foot.png'),
                    SizedBox(width: 5),
                    CustomContainer(imagePath: 'assets/images/png/finger.png'),
                    SizedBox(width: 5),
                    CustomContainer(imagePath: 'assets/images/png/girl1.png'),
                    SizedBox(width: 5),
                    CustomContainer(imagePath: 'assets/images/png/lip.png'),
                  ],
                ),
                const Spacer(),
                Center(
                  child: Text(
                    'People who set reminders tend to\nachieve their goals more frequently',
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
                SizedBox(height: 23),
                Center(
                  child: CustomGradientButton(text: 'Set reminders',
                      onPressed: (){
                        _showNotificationDialog(context);
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
  final String text;
  final bool showBlackInnerBox;

  const CustomListTile({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.text,
    this.showBlackInnerBox = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 361,
      height: 73,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 1),
        borderRadius: BorderRadius.circular(17),
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Color(0xffFFF0FA),
              shape: BoxShape.circle,
            ),
            child: showBlackInnerBox
                ? Container(
              margin: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Image.asset(imagePath),
              ),
            )
                : Image.asset(imagePath),
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
          SizedBox(width: 58),
          Text(
            text,
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class CustomContainer extends StatelessWidget {
  final String imagePath;
  const CustomContainer({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 29,
      height: 29,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Image.asset(imagePath),
    );
  }
}

void _showNotificationDialog(context){
  showDialog(
    context: context,
    builder: (context) => Padding(
      padding: const EdgeInsets.only(top: 44),
      child: const NotificationDialog(),
    ),
  );
}


