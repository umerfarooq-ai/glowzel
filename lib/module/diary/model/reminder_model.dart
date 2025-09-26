class ReminderModel {
  final String name;
  final String time;
  final String frequency;
  final String selectedDays;

  ReminderModel({
    required this.name,
    required this.time,
    required this.frequency,
    required this.selectedDays,
  });

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      name: json['name'],
      time: json['time'],
      frequency: json['frequency'],
      selectedDays: json['selected_days'],
    );
  }
}
