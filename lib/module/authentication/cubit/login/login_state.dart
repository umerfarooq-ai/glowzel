part of 'login_cubit.dart';

enum LoginStatus {
  initial,
  loading,
  success,
  error,
}

class LoginState extends Equatable {
  final LoginStatus loginStatus;
  final bool isPasswordHidden;
  final bool isConfirmPasswordHidden;
  final bool isAutoValidate;
  final String errorMessage;
  final String userId;

  LoginState({
    required this.loginStatus,
    required this.isPasswordHidden,
    required this.isConfirmPasswordHidden,
    required this.isAutoValidate,
    required this.errorMessage,
    required this.userId,
  });

  factory LoginState.initial() {
    return LoginState(
      loginStatus: LoginStatus.initial,
      isPasswordHidden: true,
      isConfirmPasswordHidden: true,
      isAutoValidate: false,
      errorMessage: '',
      userId: '-1',
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [loginStatus, isPasswordHidden, isAutoValidate];

  LoginState copyWith({
    LoginStatus? loginStatus,
    bool? isPasswordHidden,
    bool? isConfirmPasswordHidden,
    bool? isAutoValidate,
    String? errorMessage,
    String? userId,
  }) {
    return LoginState(
      loginStatus: loginStatus ?? this.loginStatus,
      isPasswordHidden: isPasswordHidden ?? this.isPasswordHidden,
      isConfirmPasswordHidden:
          isConfirmPasswordHidden ?? this.isConfirmPasswordHidden,
      isAutoValidate: isAutoValidate ?? this.isAutoValidate,
      errorMessage: errorMessage ?? this.errorMessage,
      userId: userId ?? this.userId,
    );
  }
}
