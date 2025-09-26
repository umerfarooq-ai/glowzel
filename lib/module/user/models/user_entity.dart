class UserEntity {
  final String name;
  final String email;
  final String? avatar;

  UserEntity({
    required this.name,
    required this.email,
    required this.avatar,
  });

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      name: json['name'],
      email: json['email'],
      avatar: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'avatar': avatar,
    };
  }

// UserModel toUserModel(String id) {
//   return UserModel(id: id, name: name, email: email, avatar: avatar);
// }
}
