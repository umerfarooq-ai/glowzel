import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../Constant/app_color.dart';

class GreetingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    int currentHour = DateTime.now().hour;

    String greeting;
    if (currentHour >= 5 && currentHour < 12) {
      greeting = 'Morning';
    } else if (currentHour >= 12 && currentHour < 17) {
      greeting = 'Afternoon';
    } else if (currentHour >= 17 && currentHour < 20) {
      greeting = 'Evening';
    } else {
      greeting = 'Night';
    }

    return Row(
      children: [
        Text(
          greeting,
          style: GoogleFonts.montserrat(
            color: Colors.black,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
