enum ForgotPasswordStatus {
  none,
  sending,
  sent,
  verifying,
  verified,
  updating,
  updated,
  failure,
}

class ForgotPasswordState {
  final ForgotPasswordStatus forgotPasswordStatus;
  final String message;
  final bool isPasswordHidden;
  final bool autoValidate;
  final String? verifiedOtp;
  final String? verifiedEmail;

  const ForgotPasswordState({
    this.forgotPasswordStatus = ForgotPasswordStatus.none,
    this.message = '',
    this.isPasswordHidden = true,
    this.autoValidate = false,
    this.verifiedOtp,
    this.verifiedEmail,
  });

  factory ForgotPasswordState.initial() => const ForgotPasswordState();

  ForgotPasswordState copyWith({
    ForgotPasswordStatus? forgotPasswordStatus,
    String? message,
    bool? isPasswordHidden,
    bool? autoValidate,
    String? verifiedOtp,
    String? verifiedEmail,
  }) {
    return ForgotPasswordState(
      forgotPasswordStatus: forgotPasswordStatus ?? this.forgotPasswordStatus,
      message: message ?? this.message,
      isPasswordHidden: isPasswordHidden ?? this.isPasswordHidden,
      autoValidate: autoValidate ?? this.autoValidate,
      verifiedOtp: verifiedOtp ?? this.verifiedOtp,
      verifiedEmail: verifiedEmail ?? this.verifiedEmail,
    );
  }
}