import 'package:dio/dio.dart';

import '../../utils/logger/logger.dart';

class ApiError implements Exception {
  final int? code;
  final String? message;

  ApiError({
    this.code,
    required this.message,
  });

  factory ApiError.fromDioException(DioException dioException) {
    final _log = logger(ApiError);
    if (dioException.response != null) {
      _log.e('ApiError.fromDioException: ${dioException.response?.data}');
      switch (dioException.response?.statusCode) {
        case 400: // Bad Request
        case 409: // Conflict
          return ApiError(
            code: dioException.response?.statusCode,
            message: dioException.response?.data['error'] ?? 'User already exists.',
          );
        case 401: // Invalid credentials
          return ApiError(
            code: dioException.response?.statusCode,
            message: 'Invalid credentials. Please try again.',
          );
        case 404: // Not Found
          return ApiError(
            code: dioException.response?.statusCode,
            message: 'User not found.',
          );
        case 403: // Forbidden - User already exists
          return ApiError(
            code: dioException.response?.statusCode,
            message: dioException.response?.data['error'] ?? 'User already exists.',
          );
        case 500: // Internal Server Error
          return ApiError(
            code: dioException.response?.statusCode,
            message: 'Internal server error. Please try again later.',
          );
        case 503: // Service Unavailable
          return ApiError(
            code: dioException.response?.statusCode,
            message: 'Service unavailable. Please check your connection.',
          );
        default:
          return ApiError(
            code: dioException.response?.statusCode ?? 0,
            message: dioException.response?.data['message'] ?? 'An unknown error occurred.',
          );
      }
    }

    // Handle network errors
    if (dioException.type == DioExceptionType.unknown) {
      return ApiError(
        code: 503,
        message: 'No internet connection.',
      );
    } else if (dioException.type == DioExceptionType.connectionError) {
      return ApiError(
        code: 503,
        message: 'Connection error. Please check your network.',
      );
    }

    // Timeout errors
    if (dioException.type == DioExceptionType.connectionTimeout ||
        dioException.type == DioExceptionType.sendTimeout ||
        dioException.type == DioExceptionType.receiveTimeout) {
      return ApiError(
        code: 0,
        message: 'Request timed out. Please try again.',
      );
    }

    return ApiError(
      code: dioException.response?.statusCode ?? 0,
      message: dioException.message,
    );
  }

  @override
  String toString() {
    return 'ApiError(code: $code, message: $message)';
  }
}
