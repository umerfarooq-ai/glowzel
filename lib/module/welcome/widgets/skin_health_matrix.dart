import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

import '../../../Constant/app_color.dart';

class HealthMatrixChart extends StatelessWidget {
  final List<HealthMetric> metrics;
  final double size;
  final Color primaryColor;
  final Color secondaryColor;

  const HealthMatrixChart({
    Key? key,
    required this.metrics,
    this.size = 300,
    this.primaryColor =  AppColors.lightGreen,
    this.secondaryColor = AppColors.lightGreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      child: CustomPaint(
        painter: HealthMatrixPainter(
          metrics: metrics,
          primaryColor: primaryColor,
          secondaryColor: secondaryColor,
        ),
      ),
    );
  }
}

class HealthMetric {
  final String name;
  final double value; // 0.0 to 1.0
  final double angle; // in radians
  final double score; // in radians

  HealthMetric({
    required this.name,
    required this.value,
    required this.angle,
    required this.score,
  });
}

class HealthMatrixPainter extends CustomPainter {
  final List<HealthMetric> metrics;
  final Color primaryColor;
  final Color secondaryColor;

  HealthMatrixPainter({
    required this.metrics,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 30;
    final metricCount = metrics.length;

    final angles = List.generate(
      metricCount,
          (i) => (2 * math.pi / metricCount) * i - math.pi / 2,
    );

    _drawPolygonGrid(canvas, center, radius, metricCount, angles);
    _drawRadialLines(canvas, center, radius, angles);
    _drawDataPoints(canvas, center, radius, angles);
    _drawLabels(canvas, center, radius, angles);
  }

  void _drawPolygonGrid(Canvas canvas, Offset center, double radius, int count, List<double> angles) {
    const steps = 9; // Total 9 circles
    final stepRadius = radius / steps;

    for (int i = 1; i <= steps; i++) {
      final r = stepRadius * i;
      final path = Path();
      for (int j = 0; j < count; j++) {
        final x = center.dx + r * math.cos(angles[j]);
        final y = center.dy + r * math.sin(angles[j]);
        if (j == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;

      if (i > 6) {
        paint.color = AppColors.lightGreen;
      }
      else if(i > 3) {
        paint.shader = ui.Gradient.linear(
          Offset(center.dx, center.dy - r),
          Offset(center.dx, center.dy + r),
          [
            AppColors.lightGreen.withOpacity(0.4), // 50% opacity green
            Colors.white,
          ],
        );
      }
      else {
        paint.shader = ui.Gradient.linear(
          Offset(center.dx, center.dy - r),
          Offset(center.dx, center.dy + r),
          [
            AppColors.grey, // 8% opacity green
            Colors.white,
          ],
        );
      }

      canvas.drawPath(path, paint);
    }
  }

  void _drawRadialLines(Canvas canvas, Offset center, double radius, List<double> angles) {
    for (final angle in angles) {
      final endX = center.dx + radius * math.cos(angle);
      final endY = center.dy + radius * math.sin(angle);

      final paint = Paint()
        ..strokeWidth = 1
        ..shader = ui.Gradient.linear(
          center,
          Offset(endX, endY),
          [
            AppColors.lightGreen,
            Colors.white,
          ],
        );

      canvas.drawLine(center, Offset(endX, endY), paint);
    }
  }

  void _drawDataPoints(Canvas canvas, Offset center, double radius, List<double> angles) {
    final dotPaint = Paint()
      ..color = Color(0xff264919).withOpacity(0.61)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < metrics.length; i++) {
      final value = metrics[i].value;
      final angle = angles[i];
      final r = radius * value;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      canvas.drawCircle(Offset(x, y), 3.5, dotPaint);
    }
  }

  void _drawLabels(Canvas canvas, Offset center, double radius, List<double> angles) {
    for (int i = 0; i < metrics.length; i++) {
      final metric = metrics[i];
      final labelRadius = radius + 20;
      final angle = angles[i];
      final x = center.dx + labelRadius * math.cos(angle);
      final y = center.dy + labelRadius * math.sin(angle);

      final nameText = TextSpan(
        text: metric.name,
        style: GoogleFonts.poppins(
          color: Colors.black,
          fontSize: 10,
          fontWeight: FontWeight.w300,
        ),
      );

      final scoreText = TextSpan(
        text: '${metric.score}',
        style: GoogleFonts.poppins(
          color: Colors.black,
          fontSize: 8,
          fontWeight: FontWeight.w300,
        ),
      );

      final namePainter = TextPainter(
        text: nameText,
        textDirection: TextDirection.ltr,
      )..layout();

      final scorePainter = TextPainter(
        text: scoreText,
        textDirection: TextDirection.ltr,
      )..layout();

      final totalHeight = namePainter.height + scorePainter.height;
      final offsetX = x - namePainter.width / 2;
      final offsetY = y - totalHeight / 2;

      // Draw name
      namePainter.paint(canvas, Offset(offsetX, offsetY));

      // Draw score below name
      scorePainter.paint(canvas, Offset(x - scorePainter.width / 2, offsetY + namePainter.height));
    }
  }


  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
