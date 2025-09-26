import 'dart:developer';

import 'package:bloc/bloc.dart';
import '../../../../core/exceptions/api_error.dart';
import '../../model/auth_response.dart';
import '../../model/profile_input.dart';
import '../../model/signup_input.dart';
import '../../repository/auth_repository.dart';
import 'signup_state.dart';

class SignupCubit extends Cubit<SignupState> {
  final AuthRepository _authRepository;

  void enableAutoValidateMode() => emit(state.copyWith(
    isAutoValidate: true,
    signupStatus: SignupStatus.initial,
  ));

  void toggleShowPassword() => emit(state.copyWith(
    isPasswordHidden: !state.isPasswordHidden,
    signupStatus: SignupStatus.initial,
  ));

  void toggleShowConfirmPassword() => emit(state.copyWith(
    isConfirmPasswordHidden: !state.isConfirmPasswordHidden,
    signupStatus: SignupStatus.initial,
  ));

  SignupCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(SignupState.initial());

  Future<void> resendOtpForSignup(String email) async {
    if (isClosed) return;
    emit(state.copyWith(
      signupStatus: SignupStatus.loading,
      email: email,
    ));

    try {
      await _authRepository.resendActivationOtp(email);
      if (isClosed) return;
      emit(state.copyWith(
        signupStatus: SignupStatus.otpSent,
        errorMessage: '',
        email: email,
      ));
    } on ApiError catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        signupStatus: SignupStatus.otpError,
        errorMessage: e.message,
      ));
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        signupStatus: SignupStatus.otpError,
        errorMessage: 'Failed to send OTP',
      ));
    }
  }

  Future<void> verifyOtp(String email,String otp,String purpose) async {
    if (isClosed) return;
    emit(state.copyWith(signupStatus: SignupStatus.otpVerifying));
    print("Calling verifyOtp with email: $email");

    try {
      bool isVerified = await _authRepository.verifyActivationOtp(email, otp, purpose);
      if (isVerified) {
        if (isClosed) return;
        emit(state.copyWith(
          signupStatus: SignupStatus.otpVerified,
          errorMessage: '',
        ));
      } else {
        if (isClosed) return;
        emit(state.copyWith(
          signupStatus: SignupStatus.otpError,
          errorMessage: 'Invalid OTP',
        ));
      }
    } on ApiError catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        signupStatus: SignupStatus.otpError,
        errorMessage: e.message,
      ));
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        signupStatus: SignupStatus.otpError,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> signup(SignupInput signupInput, context) async {
    if (isClosed) return;
    emit(state.copyWith(signupStatus: SignupStatus.loading));
    try {
      final email = await _authRepository.signup(signupInput, context);

      if (isClosed) return;
      emit(state.copyWith(
        signupStatus: SignupStatus.success,
        errorMessage: '',
        email: email,
      ));
    }
    on ApiError catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        signupStatus: SignupStatus.error,
        errorMessage: e.message,
      ));
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        signupStatus: SignupStatus.error,
        errorMessage: 'An unexpected error occurred',
      ));
    }
  }

  // Reset state for retry
  void resetState() {
    emit(SignupState.initial());
  }
}