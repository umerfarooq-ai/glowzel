import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../Constant/app_color.dart';

class DailyLogSlider extends StatefulWidget {
  final String? text;
  final double? value; // backend value in ml
  final ValueChanged<double>? onChanged;

  const DailyLogSlider({Key? key, this.text, this.onChanged, this.value}) : super(key: key);

  @override
  State<DailyLogSlider> createState() => _DailyLogSliderState();
}

class _DailyLogSliderState extends State<DailyLogSlider> {
  late double _sliderValue;

  static const double stepMl = 200.0; // each step ~200ml
  static const double maxMl = 800.0;

  @override
  void initState() {
    super.initState();
    // convert backend ml to slider value (0-4 scale)
    _sliderValue = ((widget.value ?? 0) / stepMl).clamp(0.0, maxMl / stepMl);
  }

  @override
  void didUpdateWidget(covariant DailyLogSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      // update slider value if backend value changes
      _sliderValue = ((widget.value ?? 0) / stepMl).clamp(0.0, maxMl / stepMl);
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      double newSliderPosition = details.localPosition.dx / 65.0;
      _sliderValue = newSliderPosition.clamp(0.0, maxMl / stepMl);
      if (widget.onChanged != null) {
        widget.onChanged!(_sliderValue * stepMl); // return ml value to parent
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double maxTrackWidth = 320;
    double knobPosition =
    (_sliderValue * 65).clamp(0.0, maxTrackWidth - 30.0);

    int ml = (_sliderValue * stepMl).round().clamp(0, maxMl.toInt());
    int glasses = (ml / stepMl).round();

    String getEmoji() {
      return 'assets/images/svg/drop2.svg';
    }

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RichText(
            text: TextSpan(
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              children: [
                TextSpan(
                  text: '$ml ml',
                  style: const TextStyle(
                    decoration: TextDecoration.underline,
                  ),
                ),
                TextSpan(text: '  ($glasses glass)'),
              ],
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onPanUpdate: _onPanUpdate,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: maxTrackWidth,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xffEAEAEA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                Container(
                  width: knobPosition + 15,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.lightGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                Positioned(
                  top: -10,
                  left: knobPosition,
                  child: SvgPicture.asset(
                    getEmoji(),
                    width: 30,
                    height: 30,
                    fit: BoxFit.scaleDown,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}
