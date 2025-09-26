import 'package:Glowzel/module/authentication/pages/login_page.dart';
import 'package:Glowzel/ui/widget/nav_router.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../Constant/app_color.dart';

class NotificationDialog extends StatefulWidget {
  const NotificationDialog({super.key});

  @override
  State<NotificationDialog> createState() =>
      _NotificationDialogState();
}

class _NotificationDialogState extends State<NotificationDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 280,
        height: 291,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 4,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  'assets/images/png/bell.png',
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '“Glowzel” would like to\nsend you notifications',
                style: GoogleFonts.montserrat(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              Text(
                'Notification may include alerts,\nsounds, and icon badges. These\ncan be configured in Settings.',
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              CustomBuildElevatedButton(text: 'Allow', color: AppColors.lightGreen,
                onPressed: () {NavRouter.pushAndRemoveUntil(context,LoginPage()); },),
              SizedBox(height: 10),
              CustomBuildElevatedButton(text: 'Don’t Allow', color: AppColors.white,
                onPressed: () {NavRouter.pushAndRemoveUntil(context,LoginPage()); },),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomBuildElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;
  final Color textColor;
  const CustomBuildElevatedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.fontSize=16,
    this.fontWeight=FontWeight.w400,
    required this.color,
    this.textColor=Colors.black,
  });




  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Rounded corners
        ),
        fixedSize: const Size(185, 38),
        shadowColor: AppColors.black,
        elevation: 4,
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: textColor,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      ),
    );
  }
}
