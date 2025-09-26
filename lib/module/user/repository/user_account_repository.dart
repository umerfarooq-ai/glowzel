import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:Glowzel/module/profile/model/update_profile_input1.dart';
import 'package:dio/dio.dart';
import '../../../Constant/api_endpoints.dart';
import '../../../Constant/keys.dart';
import '../../../core/exceptions/api_error.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/security/secure_auth_storage.dart';
import '../../../core/storage_services/storage_service.dart';
import '../../../utils/logger/logger.dart';

import '../../authentication/repository/session_repository.dart';
import '../../profile/model/update_profile_input.dart';
import '../../user/models/user_model.dart';

class UserAccountRepository {
  StorageService storageService;
  SessionRepository sessionRepository;
  DioClient dioClient;

  UserAccountRepository({
    required this.storageService,
    required this.sessionRepository,
    required this.dioClient,
  });

  final _log = logger(UserAccountRepository);
  Future<void> saveUserInDb(UserModel userModel) async {
    final userMap = userModel.toJson();
    log("Saving user data: ${json.encode(userMap)}");

    await storageService.setString(StorageKeys.user, json.encode(userMap));
    _log.i('user saved in db');
  }

  UserModel getUserFromDb() {
    final userString = storageService.getString(StorageKeys.user);
    if (userString.isNotEmpty) {
      final Map<String, dynamic> userMap = jsonDecode(userString);
      UserModel userModel = UserModel.fromJson(userMap);
      _log.i('user loaded from local db $userModel');
      return userModel;
    } else {
      return UserModel(id: '', firstname: '', lastname: '', email: '', token: '');
    }
  }
  final authStorage = AuthSecuredStorage();
  Future<UserModel> updateProfile(UpdateProfileInput input,File? image) async {
    final requestData = {
      "first_name": input.firstName,
      "last_name": input.lastName,
    };
   String? token=await authStorage.readToken();
   log("My Toiken$token");
    if (token == null) {
      log("Token not exist ");
    }else{
      dioClient.setToken(token);
    }
    try {
      String? base64Image;
      if (image != null) {
        base64Image = base64Encode(await image.readAsBytes());
      }

      if (base64Image != null) {
        requestData["image"] = base64Image;
      }


      var response = await dioClient.put(
        Endpoints.updateProfile,
        data: jsonEncode(requestData),

      );

      log("Response Status: ${response.statusCode}");
      log("Response Data: ${response.data}");

      if (response.statusCode == 200 && response.data != null) {
        if (response.data.containsKey('first_name') &&
            response.data.containsKey('last_name') &&
            response.data.containsKey('email')) {
          UserModel userModel = UserModel.fromJson(response.data);
          await saveUserInDb(userModel);
          return UserModel(id: '', firstname: '', lastname: '', email: '', token: '');
        } else {
          throw ApiError(message: 'Unexpected response structure', code: 0);
        }
      } else {
        throw ApiError(message: 'Invalid response from the server', code: 0);
      }
    } on DioException catch (e, stackTrace) {
      _log.e("DioException: ${e.message}", stackTrace: stackTrace);
      throw ApiError.fromDioException(e);
    } catch (e) {
      _log.e("Unknown error: $e");
      throw ApiError(message: 'Unknown error', code: 0);
    }
  }

  Future<UserModel> updateUserProfile1(UpdateProfileInput1 input) async {
    String? token = await authStorage.readToken();
    if (token == null) {
      log("Token not exist");
      throw ApiError(message: "Authentication required", code: 401);
    } else {
      dioClient.setToken(token);
    }

    try {
      final response = await dioClient.put(
        Endpoints.updateProfile1,
        data: input.toJson(),
      );

      log("Response Status: ${response.statusCode}");
      log("Response Data: ${response.data}");

      if (response.statusCode == 200 && response.data != null) {
        UserModel userModel = UserModel.fromJson(response.data);
        await saveUserInDb(userModel);
        return userModel;
      } else {
        throw ApiError(message: 'Invalid response from server', code: 0);
      }
    } on DioException catch (e, stackTrace) {
      _log.e("DioException: ${e.message}", stackTrace: stackTrace);
      throw ApiError.fromDioException(e);
    } catch (e) {
      _log.e("Unknown error: $e");
      throw ApiError(message: 'Unknown error', code: 0);
    }
  }


  Future<void> removeUserFromDb() async {
    await storageService.remove(StorageKeys.user);
    _log.i('user removed from db');
  }

  Future<void> deleteAccount() async {
    String? token = await authStorage.readToken();
    log("Token for delete: $token");

    if (token == null) {
      throw ApiError(message: "Authorization token missing", code: 401);
    }

    dioClient.setToken(token);

    try {
      final response = await dioClient.delete(Endpoints.deleteAccount);
      await sessionRepository.setLoggedIn(false);
      if (response.statusCode == 204) {
        log("Account successfully deleted.");
      } else {
        throw ApiError(message: 'Failed to delete account', code: response.statusCode ?? 0);
      }
    } on DioException catch (e) {
      _log.e("Delete Account Error: ${e.message}");
      throw ApiError.fromDioException(e);
    }
  }



  Future<void> logout() async {
    _log.i('Logging out user...');
    await sessionRepository.setLoggedIn(false);
    await sessionRepository.removeToken();
    await sessionRepository.clearLocalStorage();
    await removeUserFromDb();
    _log.i('logout successfully');
  }
}
