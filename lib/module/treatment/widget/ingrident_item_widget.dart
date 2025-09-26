import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../Constant/app_color.dart';

class Steps extends StatelessWidget {
  final String text;
  final String subText;
  final bool isChecked;
  final Function(bool) onChecked;

  const Steps({
    Key? key,
    required this.text,
    required this.subText,
    required this.isChecked,
    required this.onChecked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Text(text,style: GoogleFonts.poppins(
                fontSize: 16, fontWeight: FontWeight.w500)),
            Spacer(),
            InkWell(
              onTap: () => onChecked(!isChecked),
              child: Container(
                width: 17,
                height: 17,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xffC0F698).withOpacity(0.41),
                  border: Border.all(color: Color(0xff7FAE5C),width: 1),
                ),
                child: isChecked ? Icon(Icons.check, color: Colors.black, size: 14) : null,
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(subText, style: GoogleFonts.poppins(
            fontSize: 14, fontWeight: FontWeight.w300)),
      ],
    );
  }
}
