import 'package:flutter/material.dart';

class ProgressLineWidget extends StatelessWidget {
  final double score;
  final Color activeColor;
  final Color backgroundColor;

  const ProgressLineWidget({
    Key? key,
    required this.score,
    this.activeColor = const Color(0xff7FAE5C),
    this.backgroundColor = const Color(0xffD9D9D9),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: 361,
          height: 3,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: (score.clamp(0, 100)) / 100, // safe range 0–1
            child: Container(
              decoration: BoxDecoration(
                color: activeColor,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        SizedBox(height: 2),
        Text('${score.toInt()}%',style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w400,
          color: Colors.black,
        ),),
      ],
    );
  }
}
