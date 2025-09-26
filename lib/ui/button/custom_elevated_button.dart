import 'package:Glowzel/Constant/app_color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class CustomElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double fontSize;
  final FontWeight fontWeight;
  final Widget? prefixIcon;
  final Color color;
  final Color textColor;
  final Color borderColor;

  const CustomElevatedButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.prefixIcon,
    this.fontSize = 16.0,
    this.fontWeight = FontWeight.w600,
    this.color = AppColors.lightGreen,
    this.textColor = AppColors.black,
    this.borderColor = Colors.transparent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        side: BorderSide(color: borderColor, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        fixedSize: const Size(361, 48),
        shadowColor: AppColors.black,
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (prefixIcon != null) ...[
            prefixIcon!,
            const SizedBox(width: 12),
          ],
          Text(
            text,
            style: GoogleFonts.poppins(
              color: textColor,
              fontSize: fontSize,
              fontWeight: fontWeight,
            ),
          ),
        ],
      ),
    );
  }
}

