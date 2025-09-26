part of 'user_cubit.dart';

enum UserStatus {
  initial,
  loading,
  loginOut,
  updating,
  updated,
  success,
  error,
}

class UserState extends Equatable {
  final UserStatus userStatus;
  final UserModel userModel;
  final String errorMessage;

  UserState({
    required this.userStatus,
    required this.userModel,
    required this.errorMessage,
  });

  factory UserState.initial() {
    return UserState(
      userStatus: UserStatus.initial,
      userModel: UserModel.empty,
      errorMessage: '',
    );
  }

  UserState copyWith({
    UserStatus? userStatus,
    UserModel? userModel,
    String? errorMessage,
  }) {
    return UserState(
      userModel: userModel ?? this.userModel,
      userStatus: userStatus ?? this.userStatus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [userModel, userStatus];
}
