import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../Constant/app_color.dart';

class TimerWidget extends StatefulWidget {
  const TimerWidget({Key? key}) : super(key: key);

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  double _progress = 0.0;
  int _totalTime = 0;
  int _remainingTime = 0;
  Timer? _timer;
  bool _isRunning = false;

  final TextEditingController _minuteController = TextEditingController();

  void _startTimer(int seconds) {
    _timer?.cancel();
    setState(() {
      _totalTime = seconds;
      _remainingTime = seconds;
      _progress = 1.0;
      _isRunning = true;
    });


    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
          _progress = _remainingTime / _totalTime;
        });
      } else {
        timer.cancel();
        setState(() {
          _isRunning = false;
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _remainingTime = 0;
      _isRunning = false;
    });
  }


  void _showTimePickerDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Enter Timer Duration (minutes)'),
          content: TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'e.g. 1 for 1 minute',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                final minutes = int.tryParse(_minuteController.text) ?? 0;
                if (minutes > 0) {
                  final seconds = minutes * 60;
                  _startTimer(seconds);
                  Navigator.pop(context);
                }
              },
              child: const Text('Start'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _minuteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 211,
              height: 211,
              child: CustomPaint(
                painter: CirclePainter(_progress, AppColors.lightGreen),
              ),
            ),
            Column(
              children: [
                GestureDetector(
                  onTap: _resetTimer,
                  child: Text(
                    _remainingTime > 0
                        ? "${(_remainingTime ~/ 60).toString().padLeft(2, '0')}:${(_remainingTime % 60).toString().padLeft(2, '0')}"
                        : "00:00",
                    style: GoogleFonts.montserrat(
                        fontSize: 36, fontWeight: FontWeight.w600),
                  ),
                ),
                Text('remaining',
                  style: GoogleFonts.poppins(
                      fontSize: 12, fontWeight: FontWeight.w300),
                )
              ],
            ),
          ],
        ),
        const SizedBox(height: 22),
        GestureDetector(
          onTap: () {
            if (_isRunning) {
              _stopTimer();
            } else {
              _startTimer(15 * 60);
            }
          },
          child: Container(
            width: 100,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppColors.lightGreen,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _isRunning? SvgPicture.asset('assets/images/svg/pause.svg',fit: BoxFit.scaleDown): SvgPicture.asset('assets/images/svg/play.svg',fit:BoxFit.scaleDown),
                const SizedBox(width: 6),
                Text(
                  _isRunning ? 'Stop' : 'Start',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
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
  final double progress;
  final Color color;

  CirclePainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint backgroundPaint = Paint()
      ..color = AppColors.lightGreen
      ..strokeWidth = 15
      ..style = PaintingStyle.stroke;

    final Paint progressPaint = Paint()
      ..color = color
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 5) / 2;

    canvas.drawCircle(center, radius, backgroundPaint);

    double sweepAngle = 2 * 3.141592653589793 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.141592653589793 / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CirclePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
