import 'package:Glowzel/module/authentication/repository/auth_repository.dart';
import 'package:Glowzel/module/diary/cubit/daily_log_state.dart';
import 'package:Glowzel/module/diary/model/daily_log_input.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DailySkinLogCubit extends Cubit<DailySkinLogState> {
  final AuthRepository _authRepository;

  DailySkinLogCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(DailySkinLogState.initial());

  Future<void> createDailySkinLog(DailySkinLogInput input) async {
    emit(state.copyWith(dailySkinLogStatus: DailySkinLogStatus.loading));

    try {
      final response = await _authRepository.createDailySkinLog(input);

      if (response.success && response.data != null) {
        emit(state.copyWith(
          dailySkinLogStatus: DailySkinLogStatus.success,
          userId: response.data!.userId.toString(),
        ));
      } else {
        emit(state.copyWith(
          dailySkinLogStatus: DailySkinLogStatus.error,
          errorMessage: "Unexpected response from server.",
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        dailySkinLogStatus: DailySkinLogStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
