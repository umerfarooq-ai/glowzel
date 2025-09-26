
import 'package:Glowzel/module/authentication/model/profile_input.dart';

class SignupInput {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  ProfileInput? profile;


  SignupInput(
       {
    this.profile,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
  });

  @override
  String toString() {
    return 'SignupInput(email: $email, password: $password, firstName: $firstName, lastName: $lastName)';
  }

  Map<String, dynamic> toJson() {
    final data = {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'password': password,
      "profile": profile?.toJson()??{},
    };
    return data;
  }

}
