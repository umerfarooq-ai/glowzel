import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DateWidget1 extends StatelessWidget {
  final Color color;

  const DateWidget1({Key? key, this.color = Colors.black}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('dd MMM yyyy').format(DateTime.now());

    return Text(
      formattedDate,
      style: GoogleFonts.inter(
        color: color?? Colors.black,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
