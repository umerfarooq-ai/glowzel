
import 'package:equatable/equatable.dart';

enum DailySkinLogStatus {
  initial,
  loading,
  success,
  error,
}

class DailySkinLogState extends Equatable{
  final DailySkinLogStatus dailySkinLogStatus;
  final bool isPasswordHidden;
  final bool isConfirmPasswordHidden;
  final bool isAutoValidate;
  final String errorMessage;
  final String userId;
  final String logId;

  DailySkinLogState({
    required this.dailySkinLogStatus,
    required this.isPasswordHidden,
    required this.isConfirmPasswordHidden,
    required this.isAutoValidate,
    required this.errorMessage,
    required this.userId,
    required this.logId,
  });

  factory DailySkinLogState.initial() {
    return DailySkinLogState(
      dailySkinLogStatus: DailySkinLogStatus.initial,
      isPasswordHidden: true,
      isConfirmPasswordHidden: true,
      isAutoValidate: false,
      errorMessage: '',
      userId: '-1',
      logId: '1',
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props =>
      [dailySkinLogStatus, isPasswordHidden, isConfirmPasswordHidden, isAutoValidate, errorMessage, userId,logId];

  DailySkinLogState copyWith({
    DailySkinLogStatus? dailySkinLogStatus,
    bool? isPasswordHidden,
    bool? isConfirmPasswordHidden,
    bool? isAutoValidate,
    String? errorMessage,
    String? userId,
    String? logId,
  }) {
    return DailySkinLogState(
      dailySkinLogStatus: dailySkinLogStatus ?? this.dailySkinLogStatus,
      isPasswordHidden: isPasswordHidden ?? this.isPasswordHidden,
      isConfirmPasswordHidden:
      isConfirmPasswordHidden ?? this.isConfirmPasswordHidden,
      isAutoValidate: isAutoValidate ?? this.isAutoValidate,
      errorMessage: errorMessage ?? this.errorMessage,
      userId: userId ?? this.userId,
      logId: logId ?? this.logId,
    );
  }
}
