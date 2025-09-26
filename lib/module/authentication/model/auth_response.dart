import 'package:Glowzel/module/authentication/model/skin_profile_model.dart';

class AuthResponse {
  final String id;
  final String firstname;
  final String lastname;
  final String email;
  final String token;
  final String? image;
  final SkinProfileModel? profile;

  AuthResponse({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.token,
    this.image,
    this.profile,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      id: json["id"]?.toString() ?? '',
      firstname: json["first_name"] ?? '',
      lastname: json["last_name"] ?? '',
      email: json["email"] ?? '',
      token: json["access_token"] ?? '',
      image: json["image"],
      profile: json["profile"] != null ? SkinProfileModel.fromJson(json["profile"]) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "first_name": firstname,
    "last_name": lastname,
    "email": email,
    "access_token": token,
    "image": image,
  };
}
