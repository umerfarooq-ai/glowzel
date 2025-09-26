import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../Constant/app_color.dart';

class CalendarWidget extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const CalendarWidget({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late DateTime currentMonth;
  late DateTime selectedDate;
  List<DateTime> monthDates = [];

  @override
  void initState() {
    super.initState();
    selectedDate = widget.selectedDate;
    currentMonth = DateTime(selectedDate.year, selectedDate.month);
    _generateMonthDates(currentMonth);
  }

  @override
  void didUpdateWidget(CalendarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != selectedDate) {
      setState(() {
        selectedDate = widget.selectedDate;
        currentMonth = DateTime(selectedDate.year, selectedDate.month);
        _generateMonthDates(currentMonth);
      });
    }
  }

  void _generateMonthDates(DateTime month) {
    monthDates.clear();
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);

    for (int i = 0; i < lastDay.day; i++) {
      monthDates.add(firstDay.add(Duration(days: i)));
    }
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 61,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: monthDates.length,
        itemBuilder: (context, index) {
          final date = monthDates[index];
          bool isToday = _isSameDay(date, DateTime.now());
          bool isSelected = _isSameDay(date, selectedDate);

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedDate = date;
              });
              widget.onDateSelected(date); // callback
            },
            child: _buildDayColumn(
              _getDayName(date.weekday),
              date.day.toString().padLeft(2, '0'),
              isToday,
              isSelected,
            ),
          );
        },
      ),
    );
  }

  Widget _buildDayColumn(
      String day, String date, bool isToday, bool isSelected) {
    return Container(
      width: 38,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xffE3E9D0) : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: AppColors.black,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: isToday ? Colors.white : const Color(0xffF5F5F5),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                date,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.black,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
