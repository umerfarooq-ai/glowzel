import 'package:Glowzel/module/authentication/repository/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/skin_analysis_input.dart';
import 'skin_analysis_state.dart';

class SkinAnalysisCubit extends Cubit<SkinAnalysisState> {
  final AuthRepository _authRepository;

  SkinAnalysisCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(SkinAnalysisState.initial());

  Future<void> analyzeSkin(SkinAnalysisInput input) async {
    try {
      emit(state.copyWith(status: SkinAnalysisStatus.loading));

      final response = await _authRepository.analyzeSkin(input);

      emit(state.copyWith(
        status: SkinAnalysisStatus.success,
        responseData: response,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SkinAnalysisStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}

