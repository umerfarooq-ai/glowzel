import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../Constant/app_color.dart';

class SkinAnalysisCircleWidget extends StatelessWidget {
  final double score;

  const SkinAnalysisCircleWidget({Key? key, required this.score}) : super(key: key);

  Color _getCircleColor(double score) {
      return AppColors.purple;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.transparent, width: 23),
          ),
        ),
        Container(
          width: 23,
          height: 23,
          child: CustomPaint(
            painter: CirclePainter(score, _getCircleColor(score)),
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
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final Paint backgroundPaint = Paint()
      ..color = AppColors.grey2
      ..strokeWidth = 2
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
