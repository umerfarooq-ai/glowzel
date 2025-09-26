class DailySkinLogResponse {
  final bool success;
  final DailySkinLogData? data;

  DailySkinLogResponse({required this.success, this.data});

  factory DailySkinLogResponse.fromJson(Map<String, dynamic> json) {
    return DailySkinLogResponse(
      success: json['success'] ?? false,
      data: json['data'] != null
          ? DailySkinLogData.fromJson(json['data'])
          : null,
    );
  }
}

class DailySkinLogData {
  final String skinFeel;
  final String skinDescription;
  final String sleepHours;
  final String dietItems;
  final String waterIntake;
  final int id;
  final int userId;
  final String logDate;
  final String createdAt;

  DailySkinLogData({
    required this.skinFeel,
    required this.skinDescription,
    required this.sleepHours,
    required this.dietItems,
    required this.waterIntake,
    required this.id,
    required this.userId,
    required this.logDate,
    required this.createdAt,
  });

  factory DailySkinLogData.fromJson(Map<String, dynamic> json) {
    return DailySkinLogData(
      skinFeel: json['skin_feel'] ?? '',
      skinDescription: json['skin_description'] ?? '',
      sleepHours: json['sleep_hours'] ?? '',
      dietItems: json['diet_items'] ?? '',
      waterIntake: json['water_intake'] ?? '',
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      logDate: json['log_date'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}
