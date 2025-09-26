class SkinAnalysisResponse {
  final String scanId;
  final Map<String, num> skinHealthMatrix;
  final List<Map<String, dynamic>> amRoutine;
  final List<Map<String, dynamic>> pmRoutine;
  final String? nutritionRecommendations;
  final String? productRecommendations;
  final String? ingredientRecommendations;

  SkinAnalysisResponse({
    required this.scanId,
    required this.skinHealthMatrix,
    required this.amRoutine,
    required this.pmRoutine,
    this.nutritionRecommendations,
    this.productRecommendations,
    this.ingredientRecommendations,
  });

  factory SkinAnalysisResponse.fromJson(Map<String, dynamic> json) {
    // ✅ The API response has {"success": true, "data": {...}}
    final data = json['data'] as Map<String, dynamic>;

    return SkinAnalysisResponse(
      scanId: data['scanId'] as String,
      skinHealthMatrix: Map<String, num>.from(data['skinHealthMatrix']),
      amRoutine: List<Map<String, dynamic>>.from(
        (data['amRoutine']?['steps'] ?? []),
      ),
      pmRoutine: List<Map<String, dynamic>>.from(
        (data['pmRoutine']?['steps'] ?? []),
      ),
      nutritionRecommendations: data['nutritionRecommendations'],
      productRecommendations: data['productRecommendations'],
      ingredientRecommendations: data['ingredientRecommendations'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scanId': scanId,
      'skinHealthMatrix': skinHealthMatrix,
      'amRoutine': amRoutine,
      'pmRoutine': pmRoutine,
      'nutritionRecommendations': nutritionRecommendations,
      'productRecommendations': productRecommendations,
      'ingredientRecommendations': ingredientRecommendations,
    };
  }
}
