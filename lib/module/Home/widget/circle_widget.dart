import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../Constant/app_color.dart';

class SkinCircleWidget extends StatelessWidget {
  final double score;

  const SkinCircleWidget({Key? key, required this.score}) : super(key: key);

  Color _getCircleColor(double score) {
    if (score >= 80) {
      return Color(0xff3F641A);
    } else if (score > 50 && score<80) {
      return Color(0xffFEC002);
    } else {
      return Color(0xffE63D00);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 99,
          height: 99,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.transparent, width: 23),
          ),
        ),
        Container(
          width: 99,
          height: 99,
          child: CustomPaint(
            painter: CirclePainter(score, _getCircleColor(score)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${score.toInt()}%',
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Overall',
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
class CirclePainter extends CustomPainter {
  final double score;
  final Color color;

  CirclePainter(this.score, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    final Paint backgroundPaint = Paint()
      ..color = AppColors.grey2
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final double startAngle = -90.0;
    final double sweepAngle = 360.0 * (score / 100.0);

    canvas.drawArc(rect, startAngle * 0.0174533, 360 * 0.0174533, false, backgroundPaint);
    canvas.drawArc(rect, startAngle * 1.330, sweepAngle * 0.0174533, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
