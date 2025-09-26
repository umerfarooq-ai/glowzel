import 'package:Glowzel/Constant/app_color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomElevatedInputField extends StatelessWidget {
  const CustomElevatedInputField({
    Key? key,
    required this.hint,
    required this.text,
    required this.prefixIcon,
    this.isSelected = false,
    this.onTap,
    this.borderRadius = 25.0,
  }) : super(key: key);

  final String hint;
  final String text;
  final Widget prefixIcon;
  final bool isSelected;
  final VoidCallback? onTap;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: 73,
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
        padding: const EdgeInsets.only(left: 32,top: 6,bottom: 6,right: 12),
        child: Row(
          children: [
            prefixIcon,
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hint,
                  style: GoogleFonts.poppins(
                    color: AppColors.black, // Or AppColors.white if text should change color on selection
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  text,
                  maxLines: 3,
                  style: GoogleFonts.poppins(
                    color: AppColors.black, // Or AppColors.white if text should change color on selection
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                  ),
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }
}