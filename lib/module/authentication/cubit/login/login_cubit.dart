import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/exceptions/api_error.dart';
import '../../../../utils/logger/logger.dart';
import '../../model/auth_response.dart';
import '../../model/login_input.dart';
import '../../repository/auth_repository.dart';
part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepository _authRepository;

  LoginCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(LoginState.initial());

  final _log = logger(LoginCubit);

  void toggleShowPassword() => emit(state.copyWith(
    isPasswordHidden: !state.isPasswordHidden,
    loginStatus: LoginStatus.initial,
  ));

  void toggleShowConfirmPassword() => emit(state.copyWith(
    isConfirmPasswordHidden: !state.isConfirmPasswordHidden,
    loginStatus: LoginStatus.initial,
  ));

  void enableAutoValidateMode() => emit(state.copyWith(
    isAutoValidate: true,
    loginStatus: LoginStatus.initial,
  ));

  Future<void> login(LoginInput loginInput, context) async {
    emit(state.copyWith(loginStatus: LoginStatus.loading));

    try {
      AuthResponse authResponse = await _authRepository.login(loginInput);

      if (authResponse.token.isNotEmpty) {
        await _authRepository.sessionRepository.setToken(authResponse.token);
        log("Token Saved: ${authResponse.token}");
        final userDetails = await _authRepository.getMe();
        await _authRepository.sessionRepository.setId(userDetails.id);
        log("User ID Saved: ${userDetails.id}");

        await _authRepository.sessionRepository.setLoggedIn(true);
        log("Logged In Status Saved: true");
        emit(state.copyWith(
          loginStatus: LoginStatus.success,
        ));
      } else {
        emit(state.copyWith(
          loginStatus: LoginStatus.error,
          errorMessage: 'Login Failed',
        ));
      }
    } on ApiError catch (e) {
      emit(state.copyWith(
        loginStatus: LoginStatus.error,
        errorMessage: e.message,
      ));
    }
    catch (e) {
      log('Login error: $e');
      if (e is DioError) {
        log('Error response data: ${e.response?.data}');
        log('Error status code: ${e.response?.statusCode}');
      }
      // Handle the error
      emit(state.copyWith(
        loginStatus: LoginStatus.error,
        errorMessage: 'An unknown error occurred',
      ));
    }

  }

}
