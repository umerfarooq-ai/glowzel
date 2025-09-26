import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/exceptions/api_error.dart';
import '../../repository/auth_repository.dart';
import 'forgotPasswordState.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  ForgotPasswordCubit(this.authRepository) : super(ForgotPasswordState.initial());

  final AuthRepository authRepository;

  void toggleShowPassword() {
    emit(state.copyWith(
        isPasswordHidden: !state.isPasswordHidden,
        forgotPasswordStatus: ForgotPasswordStatus.none));
  }

  void enableAutoValidateMode() =>
      emit(state.copyWith(autoValidate: true));

  Future<void> forgotPassword(String email) async {
    emit(state.copyWith(
      forgotPasswordStatus: ForgotPasswordStatus.sending,
      message: '',
    ));

    try {
      await authRepository.forgotPassword(email);
      emit(state.copyWith(forgotPasswordStatus: ForgotPasswordStatus.sent));
    } on ApiError catch (e) {
      emit(state.copyWith(
        forgotPasswordStatus: ForgotPasswordStatus.failure,
        message: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        forgotPasswordStatus: ForgotPasswordStatus.failure,
        message: 'An unexpected error occurred.',
      ));
    }
  }

  Future<void> verifyOtpAndResetPassword({
    required String email,
    required String otpCode,
    required String password,
  }) async {
    emit(state.copyWith(
      forgotPasswordStatus: ForgotPasswordStatus.verifying,
      message: '',
    ));

    try {
      await authRepository.verifyResetOtp(
        email: email,
        otpCode: otpCode,
        password: password,
      );
      emit(state.copyWith(forgotPasswordStatus: ForgotPasswordStatus.updated));
    } on ApiError catch (e) {
      emit(state.copyWith(
        forgotPasswordStatus: ForgotPasswordStatus.failure,
        message: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        forgotPasswordStatus: ForgotPasswordStatus.failure,
        message: 'An unexpected error occurred.',
      ));
    }
  }
}
