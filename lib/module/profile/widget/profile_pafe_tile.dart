import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePageTile extends StatelessWidget {
  final String title;
  final String? trailingText;
  final String? trailingImagePath;
  final String imagePath;
  final VoidCallback? onTap;

  const ProfilePageTile({
    Key? key,
    required this.title,
    this.trailingText,
    this.trailingImagePath,
    required this.imagePath,
    this.onTap, required
  }) : super(key: key);

  @override
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            SvgPicture.asset(imagePath, width: 16, height: 16),
            SizedBox(width: 12),
            Text(
              title,
              maxLines: 3,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            Spacer(),
            if (trailingText != null)
              ConstrainedBox(
               constraints: BoxConstraints(
               maxWidth: 100,
),
                child: Text(
                  trailingText!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            if (trailingImagePath != null) ...[
              SizedBox(width: 8),
              SvgPicture.asset(trailingImagePath!),
            ],
          ],
        ),
      ),
    );
  }
}
