import 'package:flutter/material.dart';

class TimeReminderWidget extends StatefulWidget {
  const TimeReminderWidget({super.key});

  @override
  State<TimeReminderWidget> createState() => _TimeReminderWidgetState();
}

class _TimeReminderWidgetState extends State<TimeReminderWidget>
    with SingleTickerProviderStateMixin {
  final TextEditingController _timeController = TextEditingController(text: '8:00');
  bool isAM = true;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Center(
          child: SizedBox(
            width: 30,
            child: TextField(
              controller: _timeController,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color(0xff5E5E5E),
              ),
              decoration: InputDecoration.collapsed(
                hintText: '8:00',
              ),
              keyboardType: TextInputType.datetime,
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              isAM = !isAM;
            });
          },
          child: SizedBox(
            width: 50,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(0, -0.5),
                    end: Offset(0, 0),
                  ).animate(animation),
                  child: child,
                );
              },
              child: Text(
                isAM ? 'AM' : 'PM',
                key: ValueKey(isAM),
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xff5E5E5E),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
