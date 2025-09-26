class ReminderInput {
  final String name;
  final String time;
  final String frequency;
  final List<int> selectedDays;
  ReminderInput({
    required this.name,
    required this.time,
    required this.frequency,
    required this.selectedDays,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "time": time,
      "frequency": frequency.toLowerCase(),
      "selected_days": selectedDays.join(","),
    };
  }
}
