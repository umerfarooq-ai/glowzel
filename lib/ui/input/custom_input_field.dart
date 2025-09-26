import 'package:Glowzel/Constant/app_color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomInputField extends StatelessWidget {
  const CustomInputField({
    Key? key,
    required this.hint,
    this.prefixIcon,
    this.isSelected = false,
    this.onTap,
    this.borderRadius = 25.0,
  }) : super(key: key);

  final String hint;
  final Widget? prefixIcon;
  final bool isSelected;
  final VoidCallback? onTap;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: 56,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.lightGreen : AppColors.white, // Color changes based on selection
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.25),
              blurRadius: 2,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.centerLeft, // Align hint text to the left
        padding: const EdgeInsets.only(top: 18,bottom: 18,left: 37), // Padding for the text
        child: Row(
          children: [
            prefixIcon ?? const SizedBox.shrink(),
            SizedBox(width: 23),
            Text(
              hint,
              style: GoogleFonts.poppins(
                color: AppColors.black1,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}