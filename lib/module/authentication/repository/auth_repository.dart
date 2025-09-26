import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:Glowzel/module/diary/model/daily_log_input.dart';
import 'package:Glowzel/module/diary/model/daily_log_response.dart';
import 'package:Glowzel/module/diary/model/reminder_input.dart';
import 'package:Glowzel/module/diary/model/reminder_response.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '../../../Constant/api_endpoints.dart';
import '../../../Constant/keys.dart';
import '../../../core/exceptions/api_error.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/security/secure_auth_storage.dart';
import '../../../utils/display/display_utils.dart';
import '../../../utils/logger/logger.dart';
import '../../scan/model/skin_analysis_input.dart';
import '../../scan/model/skin_analysis_response.dart';
import '../../user/models/user_model.dart';
import '../../user/repository/user_account_repository.dart';
import '../model/auth_response.dart';
import '../model/login_input.dart';
import '../model/profile_input.dart';
import '../model/signup_input.dart';
import '../model/skin_profile_model.dart';
import 'session_repository.dart';

class AuthRepository {
  final DioClient _dioClient;
  final AuthSecuredStorage _authSecuredStorage;
  final UserAccountRepository _userAccountRepository;
  final SessionRepository _sessionRepository;

  final _log = logger(AuthRepository);

  AuthRepository({
    required DioClient dioClient,
    required UserAccountRepository userAccountRepository,
    required AuthSecuredStorage authSecuredStorage,
    required SessionRepository sessionRepository,
  })  : _dioClient = dioClient,
        _userAccountRepository = userAccountRepository,
        _authSecuredStorage = authSecuredStorage,
        _sessionRepository = sessionRepository;

  SessionRepository get sessionRepository => _sessionRepository;

  UserModel getUserFromDb() {
    return _userAccountRepository.getUserFromDb();
  }


  Future<AuthResponse> login(LoginInput loginInput) async {
    try {
      var response = await _dioClient.post(
        Endpoints.login,
        data: {
          'email': loginInput.email,
          'password': loginInput.password,
          'grant_type': 'password',
        },
        options: Options(
          contentType: Headers.jsonContentType,        ),
      );

      print('API Response: ${response.data}');
      AuthResponse authResponse = AuthResponse.fromJson(response.data);

      await _sessionRepository.setToken(authResponse.token);
      _dioClient.setToken(authResponse.token);
      await _sessionRepository.setLoggedIn(true);

      return authResponse;
    } on DioException catch (e, stackTrace) {
      _log.e(e, stackTrace: stackTrace);

      if (e.response != null && e.response!.statusCode == 400) {
        throw ApiError(
          message: 'Invalid credentials. Please check your username and password.',
          code: 400,
        );
      }

      throw ApiError.fromDioException(e);
    } on TypeError catch (e, stackTrace) {
      _log.e(stackTrace);
      throw ApiError(message: '$e', code: 0);
    } catch (e) {
      _log.e(e);
      throw ApiError(message: '$e', code: 0);
    }
  }

  Future<String?> signup(SignupInput signupInput, context) async {
    try {
      final signupData = {
        ...signupInput.toJson(),
      };

      final response = await _dioClient.post(Endpoints.signup, data: signupData);
      log("Signup Response: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        DisplayUtils.showSnackBar(context, 'Signup successful. Please verify OTP.');
        return signupInput.email;
      } else if (response.statusCode == 400 &&
          (response.data['detail']?.toString().toLowerCase().contains('email already registered') ?? false)) {
        DisplayUtils.showSnackBar(context, 'Email already registered');
        return null;
      } else {
        DisplayUtils.showSnackBar(context, 'Signup failed');
        return null;
      }
    } on DioException catch (e, stackTrace) {
      log("DioException in signup: $e");
      _log.e(e, stackTrace: stackTrace);

      final message = e.response?.data['detail'] ?? 'Signup failed due to network error';
      DisplayUtils.showSnackBar(context, message.toString());
    } catch (e) {
      log("Exception in signup: $e");
      DisplayUtils.showSnackBar(context, 'An unexpected error occurred');
    }
    return null;
  }

  Future<void> resendActivationOtp(String email) async {
    log('Sending resend OTP request for email: $email');
    final response = await _dioClient.post(
      Endpoints.sendActivationOtp,
      data: {'email': email},
    );
    log('Resend OTP response: ${response.data}');
  }


  Future<bool> verifyActivationOtp(String email, String otp, String purpose) async {
    final response = await _dioClient.post(Endpoints.verifyActivationOtp, data: {
      'email': email,
      'otp_code': otp,
      'purpose':purpose,
    });
    return response.statusCode == 200;
  }


  Future<void> forgotPassword(String email) async {
    try {
      var response = await _dioClient.post(
        Endpoints.forgotPassword,
        data: {"email": email},
      );
      if (response.statusCode == 200) {
        return;
      }

      throw response.data.toString();
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<void> verifyResetOtp({
    required String email,
    required String otpCode,
    required String password,
  }) async {
    try {
      var response = await _dioClient.post(
        Endpoints.resetPassword,
        data: {
          "verify_in": {
            "email": email,
            "otp_code": otpCode,
            "purpose": "activation"
          },
          "reset_in": {
            "password": password
          }
        },
      );

      if (response.statusCode == 200) {
        return;
      }

      throw response.data.toString();
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<bool> sendOtp(String phoneNumber)
  async {
    try {
      String? token = await _authSecuredStorage.readToken();

      if (token == 'empty-token' || token == null) {
        throw Exception("Token not found");
      }
      log("My Token: $token");
      _dioClient.setToken(token);
      var response = await _dioClient.post(
        Endpoints.sendOtp,
        data: {'phone': phoneNumber},
      );
      log("Delete Account Response ${response}");
      if (response.data['message'] ==
         'Delete account OTP sent successfully to your phone') {
        return true;
      }
      throw response.data['message'];
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<bool> verifyDeleteOtp(String phone, String otp) async {
    try {
      var response = await _dioClient.delete(
        Endpoints.verifyDeleteOtp,
        data: {'phone': phone, "otp": otp.toString()},
      );
      if (response.data['message'] ==
          "OPT Verified Successfully") {
        return true;
      }
      print(response.data['message']);
      throw response.data['message'];
    } on DioException catch (e, stackTrace) {
      _log.e(e, stackTrace: stackTrace);
      throw ApiError.fromDioException(e);
    } on TypeError catch (e) {
      _log.e(e.stackTrace);
      throw ApiError(message: '$e', code: 0);
    } catch (e) {
      _log.e(e);
      throw ApiError(message: '$e', code: 0);
    }
  }

  Future<UserModel> getMe() async {
    try {
      final response = await _dioClient.get(Endpoints.getUserData);
      return UserModel.fromJson(response.data);
    } catch (e) {
      throw ApiError(message: 'Failed to fetch user data');
    }
  }


  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      final token = await sessionRepository.getToken();
      print('Token retrieved: ${token != null ? "Token exists" : "No token"}');

      if (token == null || token.isEmpty) {
        throw Exception('No auth token found');
      }

      _dioClient.setToken(token);

      final response = await _dioClient.post(
        Endpoints.changePassword,
        data: {
          'old_password': oldPassword,
          'new_password': newPassword,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      return response.statusCode == 200;

    } on DioException catch (e) {
      print("DioException details:");
      print("Status code: ${e.response?.statusCode}");
      print("Response data: ${e.response?.data}");
      print("Headers: ${e.response?.headers}");

      if (e.response?.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else if (e.response?.statusCode == 422) {
        final detail = e.response?.data?['detail'];
        if (detail is List && detail.isNotEmpty) {
          throw Exception(detail.first['msg'] ?? 'Validation error');
        } else {
          throw Exception('Invalid password provided');
        }
      }

      throw Exception(e.response?.data?['detail'] ?? 'Failed to change password');
    } catch (e) {
      print("General error: $e");
      throw Exception('An unexpected error occurred');
    }
  }

  Future<SkinAnalysisResponse> analyzeSkin(SkinAnalysisInput input) async {
    final formData = FormData.fromMap(input.toFormData());

    final response = await _dioClient.post(
      Endpoints.skinAnalysis,
      data: formData,
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      final analysis = SkinAnalysisResponse.fromJson(response.data);

      await _sessionRepository.setScanId(analysis.scanId);

      return analysis;
    } else {
      throw Exception("Skin analysis failed: ${response.data}");
    }
  }


  Future<SkinAnalysisResponse?> getSkinHealth(String scanId) async {
    try {
      final response = await _dioClient.get('/api/skin-analysis/$scanId');

      if (response.statusCode == 200 && response.data != null) {
        return SkinAnalysisResponse.fromJson(response.data);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> fetchUserSkinHistory() async {
    final userId = await sessionRepository.getId();
    if (userId == null) throw Exception('User ID is null');
    final response = await _dioClient.get(
      '/api/skin-analysis/user/$userId/history',
      queryParameters: {
        'limit': 50,
        'skip': 0,
      },
    );

    if (response.statusCode == 200) {
      final jsonData = response.data is String
          ? jsonDecode(response.data)
          : response.data;

      final analyses = jsonData['data']['analyses'];

      print('✅ Total analyses from API: ${analyses.length}');
      for (var analysis in analyses) {
        print('📄 Scan ID: ${analysis['scanId']}');
      }
      print('📦 Full decoded response: ${jsonEncode(jsonData)}');

      return List<Map<String, dynamic>>.from(analyses);
    } else {
      throw Exception('❌ Failed to fetch skin history: ${response.statusCode}');
    }
  }

  Future<DailySkinLogResponse> createDailySkinLog(DailySkinLogInput input) async {
    try {
      final skinDailyLogData = input.toJson();

      final response = await _dioClient.post(
        Endpoints.skinDailyLog,
        data: skinDailyLogData,
      );

      log("DailySkinLog Response: ${response.statusCode}");

      if (response.statusCode == 200) {
        return DailySkinLogResponse.fromJson(response.data);
      } else if (response.statusCode == 422) {
        throw Exception("Validation Error: ${response.data}");
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Network Error: $e");
    }
  }

  Future<DailySkinLogResponse> getDailySkinLog(int logId) async {
    try {
      final response = await _dioClient.get('${Endpoints.skinDailyLog}/$logId');
      log("Get DailySkinLog Response: ${response.statusCode}");

      if (response.statusCode == 200) {
        return DailySkinLogResponse.fromJson(response.data);
      } else if (response.statusCode == 404) {
        throw Exception("Log not found: $logId");
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Network Error: $e");
    }
  }

  Future<List<Map<String, dynamic>>> fetchDailyLogHistory() async {
    final userId = await sessionRepository.getId();
    print('🆔 User ID: $userId');
    if (userId == null) throw Exception('User ID is null');

    final response = await _dioClient.get(
      '/api/daily-skin-log/user/$userId/history',
      queryParameters: {'limit': 50, 'skip': 0},
    );

    print('📦 Raw API response: ${response.data}');

    if (response.statusCode == 200) {
      final jsonData = response.data is String
          ? jsonDecode(response.data)
          : response.data;

      final logs = List<Map<String, dynamic>>.from(jsonData);

      print('✅ Total logs from API: ${logs.length}');
      for (var log in logs) {
        print('📄 Daily Log ID: ${log['id']}');
        print('📅 Date: ${log['log_date']}');
      }

      return logs;
    } else {
      throw Exception('❌ Failed to fetch skin history: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> updateDailySkinLog({
    required int logId,
    required Map<String, dynamic> input,
  }) async {
    final response = await _dioClient.put(
      '/api/daily-skin-log/$logId',
      data: input,
    );
    return response.data;
  }

  Future<ReminderResponse> createReminder(ReminderInput input) async {
    try {
      final response = await _dioClient.post(
        Endpoints.createReminder,
        data: input.toJson(),
      );

      log("CreateReminder Response: ${response.statusCode}");

      if (response.statusCode == 200) {
        return ReminderResponse.fromJson(response.data);
      } else if (response.statusCode == 422) {
        throw Exception("Validation Error: ${response.data}");
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Network Error: $e");
    }
  }

  Future<ReminderResponse> getReminder(int reminderId) async {
    try {
      final response = await _dioClient.get('${Endpoints.createReminder}/$reminderId');
      log("Get DailySkinLog Response: ${response.statusCode}");

      if (response.statusCode == 200) {
        return ReminderResponse.fromJson(response.data);
      } else if (response.statusCode == 404) {
        throw Exception("Reminder not found: $reminderId");
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Network Error: $e");
    }
  }

  Future<Map<String, dynamic>> updateReminder({
    required int reminderId,
    required Map<String, dynamic> input,
  }) async {
    final response = await _dioClient.put(
      '${Endpoints.createReminder}/$reminderId',
      data: input,
    );
    return response.data;
  }


  Future<Map<String, dynamic>> toggleReminder(int reminderId) async {
    final response = await _dioClient.post(
      '/api/reminders/$reminderId/toggle',
    );
    return response.data;
  }


  Future<void> updateDeviceToken(String token) async {
    try {
      final response = await _dioClient.post(
        Endpoints.updateDeviceToken,
        data: json.encode({"device_token": token}),
      );

      if (response.statusCode == 200) {
        print("✅ Device token updated successfully");
        debugPrint("✅ Token sent successfully: $token");

      } else {
        print("❌ Failed to update token: ${response.data}");
        debugPrint("❌ Failed to send token. Status: ${response.statusCode}, Body: ${response.data}");

      }
    } catch (e) {
      print("Error sending token: $e");
    }
  }


}
