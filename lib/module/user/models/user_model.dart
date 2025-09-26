class UserModel {
  final String id;
  final String firstname;
  final String lastname;
  final String email;
  final String token;
  final String? image;
  final Profile? profile;

  const UserModel({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.token,
    this.image,
    this.profile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json["id"] ?? json["_id"] ?? '').toString(),
      firstname: json["first_name"] ?? '',
      lastname: json["last_name"] ?? '',
      email: json["email"] ?? '',
      token: json["access_token"] ?? '',
      image: json["image"],
      profile: json["profile"] != null
          ? Profile.fromJson(json["profile"])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "first_name": firstname,
      "last_name": lastname,
      "email": email,
      "access_token": token,
      "image": image,
      "profile": profile?.toJson(),
    };
  }

  static const UserModel empty = UserModel(
    id: '',
    firstname: '',
    lastname: '',
    email: '',
    token: '',
    image: null,
    profile: null,
  );
}

class Profile {
  final String? dob;
  final String? gender;
  final String? skinType;
  final String? shineOnFace;
  final String? skinSensitivity;
  final List<String>? skinConcern;
  final String? skinRoutine;
  final String? skinGoals;

  const Profile({
    this.dob,
    this.gender,
    this.skinType,
    this.shineOnFace,
    this.skinSensitivity,
    this.skinConcern,
    this.skinRoutine,
    this.skinGoals,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      dob: json["date_of_birth"],
      gender: json["gender"],
      skinType: json["skin_type"],
      shineOnFace: json["shine_on_face"],
      skinSensitivity: json["skin_sensitivity"],
      skinConcern: _parseSkinConcern(json["skin_concern"]),
      skinRoutine: json["skin_care_routine"],
      skinGoals: json["skin_goals"],
    );
  }

  static List<String>? _parseSkinConcern(dynamic value) {
    if (value == null) return null;
    if (value is List) return value.map((e) => e.toString()).toList();
    return [value.toString()];
  }

  Map<String, dynamic> toJson() {
    return {
      "date_of_birth": dob,
      "gender": gender,
      "skin_type": skinType,
      "shine_on_face": shineOnFace,
      "skin_sensitivity": skinSensitivity,
      "skin_concern": skinConcern,
      "skin_care_routine": skinRoutine,
      "skin_goals": skinGoals,
    };
  }
}
