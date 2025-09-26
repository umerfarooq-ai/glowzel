class DailySkinLogInput {
  final String skinFeel;
  final String skinDescription;
  final String sleepHours;
  final String dietItems;
  final String waterIntake;

  DailySkinLogInput({
    required this.skinFeel,
    required this.skinDescription,
    required this.sleepHours,
    required this.dietItems,
    required this.waterIntake,
  });

  Map<String, dynamic> toJson() {
    return {
      "skin_feel": skinFeel,
      "skin_description": skinDescription,
      "sleep_hours": sleepHours,
      "diet_items": dietItems,
      "water_intake": waterIntake,
    };
  }
}
