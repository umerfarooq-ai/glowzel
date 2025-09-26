class UpdateReminderInput {
  final String? name;
  final String? time;
  final String? frequency;
  final String? selectedDays;

  UpdateReminderInput({
    this.name,
    this.time,
    this.frequency,
    this.selectedDays,
  });

  Map<String, dynamic> toJson() {
    return {
      if (name != null) "name": name,
      if (time != null && time!.isNotEmpty) "time": time,
      if (frequency != null && frequency!.isNotEmpty) "frequency": frequency,
      if (selectedDays != null && selectedDays!.isNotEmpty) "selected_days": selectedDays,
    };
  }
}
