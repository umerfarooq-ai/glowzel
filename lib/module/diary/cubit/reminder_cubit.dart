import 'package:Glowzel/module/authentication/repository/auth_repository.dart';
import 'package:Glowzel/module/diary/cubit/reminder_state.dart';
import 'package:Glowzel/module/diary/model/reminder_input.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReminderCubit extends Cubit<ReminderState> {
  final AuthRepository _authRepository;

  ReminderCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(ReminderState.initial());

  Future<void> createReminder(ReminderInput input) async {
    emit(state.copyWith(reminderStatus: ReminderStatus.loading));

    try {
      final response = await _authRepository.createReminder(input);

      if (response.success && response.data != null) {
        emit(state.copyWith(
          reminderStatus: ReminderStatus.success,
          userId: response.data!.userId.toString(),
        ));
      } else {
        emit(state.copyWith(
          reminderStatus: ReminderStatus.error,
          errorMessage: "Unexpected response from server.",
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        reminderStatus: ReminderStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
