import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../Constant/app_color.dart';

class DeletedSuccessfullyDialog extends StatefulWidget {
  const DeletedSuccessfullyDialog({super.key});

  @override
  State<DeletedSuccessfullyDialog> createState() =>
      _DeletedSuccessfullyDialogState();
}

class _DeletedSuccessfullyDialogState extends State<DeletedSuccessfullyDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 337,
        height: 402,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 4,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Your account have been successfully deleted.',
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
