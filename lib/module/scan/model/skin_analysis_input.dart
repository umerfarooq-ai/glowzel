import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

class SkinAnalysisInput {
  final int userId;
  final String? analysisDate;
  final File image;

  SkinAnalysisInput({
    required this.userId,
    this.analysisDate,
    required this.image,
  });

  Map<String, dynamic> toFormData() {
    return {
      'user_id': userId, // keep it as integer ✅
      if (analysisDate != null) 'analysis_date': analysisDate,
      'image': MultipartFile.fromFileSync(
        image.path,
        filename: image.path.split('/').last,
        contentType: MediaType('image', 'jpeg'), // adjust dynamically if needed
      ),
    };
  }
}
