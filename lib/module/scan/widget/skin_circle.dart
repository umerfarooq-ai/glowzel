import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../Constant/app_color.dart';

class SkinCircleScoreWidget extends StatelessWidget {
  final num score;
  final double width;
  final double height;
  final double fontSize;
  final FontWeight fontWeight;

  const SkinCircleScoreWidget({Key? key, required this.score, required this.width, required this.height, required this.fontSize, required this.fontWeight}) : super(key: key);

  Color _getCircleColor(num score) {
    if (score <= 40) {
      return AppColors.lightGreen;
    } else if (score > 40 && score<=70) {
      return Color(0xffFEC002);
    } else {
      return Color(0xffFF2009);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: width,
          height: height,
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
                    fontSize: fontSize,
                    fontWeight: fontWeight,
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
  final num score;
  final Color color;

  CirclePainter(this.score, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    final Paint backgroundPaint = Paint()
      ..color = AppColors.grey2.withOpacity(0.21)
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
