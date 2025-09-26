import 'package:equatable/equatable.dart';
import '../model/skin_analysis_response.dart';

enum SkinAnalysisStatus { initial, loading, success, failure }

class SkinAnalysisState extends Equatable {
  final SkinAnalysisStatus status;
  final SkinAnalysisResponse? responseData;
  final String errorMessage;

  const SkinAnalysisState({
    required this.status,
    this.responseData,
    this.errorMessage = '',
  });

  factory SkinAnalysisState.initial() {
    return const SkinAnalysisState(
      status: SkinAnalysisStatus.initial,
      responseData: null,
      errorMessage: '',
    );
  }

  SkinAnalysisState copyWith({
    SkinAnalysisStatus? status,
    SkinAnalysisResponse? responseData,
    String? errorMessage,
  }) {
    return SkinAnalysisState(
      status: status ?? this.status,
      responseData: responseData ?? this.responseData,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, responseData, errorMessage];
}
