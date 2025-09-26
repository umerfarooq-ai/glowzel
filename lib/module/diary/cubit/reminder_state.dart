

enum ReminderStatus {
  initial,
  loading,
  success,
  error,
}

class ReminderState{
  final ReminderStatus reminderStatus;
  final bool isPasswordHidden;
  final bool isConfirmPasswordHidden;
  final bool isAutoValidate;
  final String errorMessage;
  final String userId;
  final String logId;

  ReminderState({
    required this.reminderStatus,
    required this.isPasswordHidden,
    required this.isConfirmPasswordHidden,
    required this.isAutoValidate,
    required this.errorMessage,
    required this.userId,
    required this.logId,
  });

  factory ReminderState.initial() {
    return ReminderState(
      reminderStatus: ReminderStatus.initial,
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
      [reminderStatus, isPasswordHidden, isConfirmPasswordHidden, isAutoValidate, errorMessage, userId,logId];

  ReminderState copyWith({
    ReminderStatus? reminderStatus,
    bool? isPasswordHidden,
    bool? isConfirmPasswordHidden,
    bool? isAutoValidate,
    String? errorMessage,
    String? userId,
    String? logId,
  }) {
    return ReminderState(
      reminderStatus: reminderStatus ?? this.reminderStatus,
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
