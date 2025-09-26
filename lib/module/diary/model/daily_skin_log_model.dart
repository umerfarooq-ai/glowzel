class DailySkinLogModel {
  final int id;
  final int userId;
  final String logDate;
  final String skinFeel;
  final String skinDescription;
  final String sleepHours;
  final String dietItems;
  final String waterIntake;

  DailySkinLogModel({
    required this.id,
    required this.userId,
    required this.logDate,
    required this.skinFeel,
    required this.skinDescription,
    required this.sleepHours,
    required this.dietItems,
    required this.waterIntake,
  });

  factory DailySkinLogModel.fromJson(Map<String, dynamic> json) {
    return DailySkinLogModel(
      id: json['id'],
      userId: json['user_id'],
      logDate: json['log_date'],
      skinFeel: json['skin_feel'],
      skinDescription: json['skin_description'],
      sleepHours: json['sleep_hours'],
      dietItems: json['diet_items'],
      waterIntake: json['water_intake'],
    );
  }
}
