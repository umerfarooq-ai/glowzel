class ReminderResponse {
  final bool success;
  final String message;
  final ReminderData? data;

  ReminderResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ReminderResponse.fromJson(Map<String, dynamic> json) {
    return ReminderResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? ReminderData.fromJson(json['data']) : null,
    );
  }
}

class ReminderData {
  final int id;
  final int userId;
  final String name;
  final String time;
  final String frequency;
  final String selectedDays;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  ReminderData({
    required this.id,
    required this.userId,
    required this.name,
    required this.time,
    required this.frequency,
    required this.selectedDays,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReminderData.fromJson(Map<String, dynamic> json) {
    return ReminderData(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      name: json['name'] ?? '',
      time: json['time'] ?? '',
      frequency: json['frequency'] ?? '',
      selectedDays: json['selected_days'] ?? '',
      isActive: json['is_active'] ?? false,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}
