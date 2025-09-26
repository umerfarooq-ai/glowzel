import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../Constant/app_color.dart';

class CustomGradientButton extends StatelessWidget {
  const CustomGradientButton({
    required this.text,
    required this.onPressed,
    this.width = 266,
    this.height = 48,
    this.borderRadius = 17.0,
    this.backgroundColor = Colors.white,
    this.borderColor = const Color(0xFFFFFFFF),
    this.textColor = AppColors.black,
    this.fontSize = 14.0,
    this.fontWeight = FontWeight.w400,
    this.borderWidth = 1.0,
    this.iconWidget,
    this.iconSize = 20.0,
    this.isLoading = false,
    super.key,
  });

  final String text;
  final VoidCallback? onPressed;
  final double width;
  final double height;
  final double borderRadius;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final double fontSize;
  final FontWeight fontWeight;
  final double borderWidth;
  final Widget? iconWidget;
  final double iconSize;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
       color: AppColors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ]
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLoading)
                  SizedBox(
                    width: iconSize,
                    height: iconSize,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation<Color>(textColor),
                    ),
                  )
                else if (iconWidget != null) ...[
                  SizedBox(
                    width: iconSize,
                    height: iconSize,
                    child: iconWidget,
                  ),
                  SizedBox(width:14),
                ],
                  Text(
                    text,
                    style: GoogleFonts.poppins(
                      color: AppColors.black,
                      fontSize: fontSize,
                      fontWeight: fontWeight,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
