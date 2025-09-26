import 'package:dio/dio.dart';

class ProfileInput {
  final String dob;
  final String gender;
  final String skinType;
  final String skinSensitivity;
  final String skinRoutine;

  ProfileInput({
    required this.dob,
    required this.gender,
    required this.skinType,
    required this.skinSensitivity,
    required this.skinRoutine,
  });

  factory ProfileInput.empty() {
    return ProfileInput(
      dob: '',
      gender: '',
      skinType: '',
      skinSensitivity: '',
      skinRoutine: '',
    );
  }

  Map<String, dynamic> toJson() => {
    "gender": gender,
    "skin_type": skinType,
    "skin_sensitivity": skinSensitivity,
    "skin_care_routine": skinRoutine,
    "date_of_birth":dob,
  };
  FormData toFormData() => FormData.fromMap({
    "gender": gender,
    "skin_type": skinType,
    "skin_sensitivity": skinSensitivity,
    "skin_care_routine": skinRoutine,
    "date_of_birth": dob,
  });
}
