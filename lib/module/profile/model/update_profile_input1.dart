class UpdateProfileInput1 {
  final String? dob;
  final String? gender;
  final String? skinType;
  final String? shineOnFace;
  final String? skinSensitivity;
  final String? skinConcern;
  final String? skinCareRoutine;
  final String? skinGoals;

  UpdateProfileInput1({
    this.dob,
    this.gender,
    this.skinType,
    this.shineOnFace,
    this.skinSensitivity,
    this.skinConcern,
    this.skinCareRoutine,
    this.skinGoals,
  });

  Map<String, dynamic> toJson() {
    return {
      if (dob != null) "date_of_birth": dob,
      if (gender != null && gender!.isNotEmpty) "gender": gender,
      if (skinType != null && skinType!.isNotEmpty) "skin_type": skinType,
      if (shineOnFace != null && shineOnFace!.isNotEmpty) "shine_on_face": shineOnFace,
      if (skinSensitivity != null && skinSensitivity!.isNotEmpty) "skin_sensitivity": skinSensitivity,
      if (skinConcern != null && skinConcern!.isNotEmpty) "skin_concern": skinConcern,
      if (skinCareRoutine != null && skinCareRoutine!.isNotEmpty) "skin_care_routine": skinCareRoutine,
      if (skinGoals != null && skinGoals!.isNotEmpty) "skin_goals": skinGoals,
    };
  }
}
