class UpdateDiaryInput {
  final String? skinFeel;
  final String? skinDescription;
  final String? sleepHours;
  final String? dietItems;
  final String? waterIntake;

  UpdateDiaryInput({
    this.skinFeel,
    this.skinDescription,
    this.sleepHours,
    this.dietItems,
    this.waterIntake,
  });

  Map<String, dynamic> toJson() {
    return {
      if (skinFeel != null) "skin_feel": skinFeel,
      if (skinDescription != null && skinDescription!.isNotEmpty) "skin_description": skinDescription,
      if (sleepHours != null && sleepHours!.isNotEmpty) "sleep_hours": sleepHours,
      if (dietItems != null && dietItems!.isNotEmpty) "diet_items": dietItems,
      if (waterIntake != null && waterIntake!.isNotEmpty) "water_intake": waterIntake,
    };
  }
}
