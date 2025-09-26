import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../Constant/app_color.dart';

class LineBarWidget extends StatelessWidget {
  final int score;
  const LineBarWidget ({Key? key,required this.score}): super(key: key);
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Text('${score}%',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
            ),
            SizedBox(height: 5),
            Container(
              width: 223,
              height: 9,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  colors: [
                    Color(0xff7FAE5C),
                    AppColors.grey1,
                  ],
                  stops: [score / 100, score / 100],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
