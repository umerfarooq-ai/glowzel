import 'package:equatable/equatable.dart';

enum SignupStatus {
  initial,
  loading,
  success,
  error,
  otpSent,
  otpVerifying,
  otpVerified,
  otpError,
}

class SignupState extends Equatable {
  final SignupStatus signupStatus;
  final bool isAutoValidate;
  final bool isPasswordHidden;
  final bool isConfirmPasswordHidden;
  final String errorMessage;
  final String userId;
  final String? email;

  SignupState({
    required this.signupStatus,
    required this.isAutoValidate,
    required this.isPasswordHidden,
    required this.isConfirmPasswordHidden,
    required this.errorMessage,
    required this.userId,
    required this.email,
  });

  factory SignupState.initial() {
    return SignupState(
        signupStatus: SignupStatus.initial,
        isAutoValidate: false,
        isPasswordHidden: true,
        isConfirmPasswordHidden: true,
        userId: '-1',
        email: null,
        errorMessage: '');
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props =>
      [signupStatus, isPasswordHidden, isConfirmPasswordHidden,
        isAutoValidate, errorMessage, userId, email];

  SignupState copyWith({
    SignupStatus? signupStatus,
    bool? isAutoValidate,
    bool? isPasswordHidden,
    bool? isConfirmPasswordHidden,
    String? errorMessage,
    String? userId,
    String? email,
  }) {
    return SignupState(
      signupStatus: signupStatus ?? this.signupStatus,
      isAutoValidate: isAutoValidate ?? this.isAutoValidate,
      isPasswordHidden: isPasswordHidden ?? this.isPasswordHidden,
      isConfirmPasswordHidden:
      isConfirmPasswordHidden ?? this.isConfirmPasswordHidden,
      errorMessage: errorMessage ?? this.errorMessage,
      userId: userId ?? this.userId,
      email: email ?? this.email,
    );
  }
}