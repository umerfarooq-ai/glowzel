import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../Constant/app_color.dart';

class CircleWidget extends StatelessWidget {
  final double score;

  const CircleWidget({Key? key, required this.score}) : super(key: key);

  Color _getCircleColor(double score) {
    if (score >= 12) {
      return Color(0xffE63D00);
    } else if (score >=6) {
      return Color(0xffFEC002);
    } else {
      return Color(0xff3F641A);
    }
  }

  String _getScoreLabel(double score) {
    if (score >= 12) {
      return "Extreme";
    } else if (score >= 6) {
      return "Moderate";
    } else {
      return "Mild";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 110,
          height: 110,
          child: CustomPaint(
            painter: CirclePainter(score, _getCircleColor(score)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  score.toStringAsFixed(2),
                  style: GoogleFonts.poppins(
                  color: Colors.black,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  _getScoreLabel(score),
                  style: GoogleFonts.poppins(
                  color: Colors.black,
                    fontSize: 10,
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
    final double strokeWidth = 7;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = (size.width / 2) - (strokeWidth / 2);

    final Paint backgroundPaint = Paint()
      ..color = AppColors.grey2
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Paint foregroundPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Rect rect = Rect.fromCircle(center: center, radius: radius);
    final double startAngle = -3.14 / 2;
    final double sweepAngle = 2 * 3.14 * (score / 16.0);

    // Draw background circle
    canvas.drawArc(rect, 0, 2 * 3.14, false, backgroundPaint);

    // Draw gradient arc
    canvas.drawArc(rect, startAngle, sweepAngle, false, foregroundPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
