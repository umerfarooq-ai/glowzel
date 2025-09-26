import 'package:flutter/material.dart';

import '../../../Constant/app_color.dart';

class NotificationToggle extends StatelessWidget {
  final bool isEnabled;
  final ValueChanged<bool> onToggle;

  const NotificationToggle({
    Key? key,
    required this.isEnabled,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onToggle(!isEnabled),
      child: Container(
        width: 50,
        height: 28,
        decoration: BoxDecoration(
          color: isEnabled ? Color(0xff3F641A) : Color(0xffF1F3F4),

          borderRadius: BorderRadius.circular(15),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: Duration(milliseconds: 200),
              left: isEnabled ? 22 : 0,
              top: 0,
              child: Container(
                width: 22,
                height: 22,
                margin: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white,

                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
