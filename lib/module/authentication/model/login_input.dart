import 'package:dio/dio.dart';

class LoginInput {
  final String email ;
  final String password;

  LoginInput({required this.password,required this.email});

  Map<String, dynamic> toJson() => {
        "email": email ,
        "password": password,
      };

  FormData toFormData() => FormData.fromMap({
    "email": email,
        'password': password,
      });
}
