import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../Constant/app_color.dart';

class SliderWidget extends StatefulWidget {
  final String? text;
  final double? value; 
  final ValueChanged<double>? onChanged;

  const SliderWidget({Key? key, this.text, this.onChanged, this.value}) : super(key: key);

  @override
  State<SliderWidget> createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget> {
  late double _sliderPosition;

  @override
  void initState() {
    super.initState();
    // initialize slider with backend value
    _sliderPosition = widget.value?.clamp(0.0, 4.0) ?? 2.0;
  }

  @override
  void didUpdateWidget(covariant SliderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // update slider if backend value changes
    if (oldWidget.value != widget.value && widget.value != null) {
      setState(() {
        _sliderPosition = widget.value!.clamp(0.0, 4.0);
      });
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      double newSliderPosition = details.localPosition.dx / 65.0;
      _sliderPosition = newSliderPosition.clamp(0.0, 4.0);
      if (widget.onChanged != null) {
        widget.onChanged!(_sliderPosition);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double maxTrackWidth = 320;
    double knobPosition =
    (_sliderPosition * 65).clamp(0.0, maxTrackWidth - 30.0);

    String getEmoji() {
      if (_sliderPosition <= 1.5) return 'assets/images/svg/emoji3.svg';
      if (_sliderPosition <= 3.0) return 'assets/images/svg/emoji2.svg';
      return 'assets/images/svg/emoji.svg';
    }

    String getLabel() {
      if (_sliderPosition <= 1.5) return 'Normal';
      if (_sliderPosition <= 3.0) return 'Moderate';
      return 'Rough';
    }

    Color getLabelColor() {
      if (_sliderPosition <= 1.5) return Color(0xffC0F698);
      if (_sliderPosition <= 3.0) return Color(0xffFFCA28).withOpacity(0.3);
      return Color(0xffFF2009).withOpacity(0.3);
    }

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const SizedBox(height: 8),
          GestureDetector(
            onPanUpdate: _onPanUpdate,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: maxTrackWidth,
                  height: 10,
                  decoration: BoxDecoration(
                    color:Color(0xffEAEAEA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                Container(
                  width: knobPosition + 15,
                  height: 10,
                  decoration: BoxDecoration(
                    color: getLabelColor(),
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
          Text(
            '${widget.text ?? ''} ${getLabel()}',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
