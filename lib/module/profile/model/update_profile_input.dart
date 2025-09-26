import 'package:dio/dio.dart';

class UpdateProfileInput {
  final String? firstName;
  final String? lastName;
  final MultipartFile? image;

  UpdateProfileInput({
    this.firstName,
    this.lastName,
    this.image,
  });

  FormData toFormData() {
    final Map<String, dynamic> data = {};
    if (firstName != null && firstName!.isNotEmpty) {
      data['first_name'] = firstName;
    }
    if (lastName != null && lastName!.isNotEmpty) {
      data['last_name'] = lastName;
    }
    if (image != null) {
      data['image'] = image;
    }
    return FormData.fromMap(data);
  }
}
