import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DateWidget extends StatelessWidget {
  final Color color;

  const DateWidget({Key? key, this.color = Colors.black}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('MMMM dd, EEEE').format(DateTime.now());

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
