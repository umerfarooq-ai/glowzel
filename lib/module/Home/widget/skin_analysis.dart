import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../Constant/app_color.dart';
import 'circle2_widget.dart';

class SkinAnalysisWidget extends StatelessWidget {
  const SkinAnalysisWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 184,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        gradient: LinearGradient(
            colors: [
              Color(0xffFFFFFF),
              Color(0xffFFFFFF).withOpacity(0.46),
              Color(0xffFFFFFF).withOpacity(0.2),
            ]),
        border: Border.all(
          width: 1,
          color: Colors.white,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('AI Skin Analysis',
            style: TextStyle(
                color: AppColors.black,
                fontSize: 18,
                fontWeight: FontWeight.w400),
          ),
          SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            child: GridView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 2,
                mainAxisSpacing: 6,
                childAspectRatio: 147 / 66,
              ),
              children: List.generate(4, (index) {
                final List<double> scores = [78.0, 87.0, 58.0, 63.0];
                final labels = ['Moisture level', 'Dryness', 'Texture', 'Pores visibility'];
                return Container(
                  width: 127,
                  height: 66,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    gradient: LinearGradient(
                        colors: [
                          Color(0xffFFFFFF),
                          Color(0xffFFFFFF).withOpacity(0.46),
                          Color(0xffFFFFFF).withOpacity(0.2),
                        ]),
                    border: Border.all(
                      width: 1,
                      color: Colors.white,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          labels[index],
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              '${scores[index].toInt()}%',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                            ),
                          SizedBox(width: 50),
                          SkinAnalysisCircleWidget(score: scores[index]),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          ),
        ],
      ),
    );
  }
}
