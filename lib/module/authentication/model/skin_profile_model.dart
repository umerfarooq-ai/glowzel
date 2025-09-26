class SkinProfileModel {
  final String dob;
  final int id;
  final String gender;
  final String skinType;
  final String shineOnFace;
  final String skinSensitivity;
  final String skinConcern;
  final String skinCareRoutine;
  final String skinGoals;

  SkinProfileModel({
    required this.dob,
    required this.id,
    required this.gender,
    required this.skinType,
    required this.shineOnFace,
    required this.skinSensitivity,
    required this.skinConcern,
    required this.skinCareRoutine,
    required this.skinGoals,
  });

  factory SkinProfileModel.fromJson(Map<String, dynamic> json) {
    return SkinProfileModel(
      dob: json["date_of_birth"],
      id: json["user_id"],
      gender: json["gender"],
      skinType: json["skin_type"],
      shineOnFace: json["shine_on_face"],
      skinSensitivity: json["skin_sensitivity"],
      skinConcern: json["skin_concern"],
      skinCareRoutine: json["skin_care_routine"],
      skinGoals: json["skin_goals"],
    );
  }
}
