// lib/models/prediction_model.dart

class PredictionResponse {
  final String message;
  final String predictedOutcome;
  final int confidenceScore;
  final String reasoning;

  PredictionResponse({
    required this.message,
    required this.predictedOutcome,
    required this.confidenceScore,
    required this.reasoning,
  });

  factory PredictionResponse.fromJson(Map<String, dynamic> json) {
    return PredictionResponse(
      message: json['message'] as String? ?? 'Prediction generated.',
      predictedOutcome: json['predicted_outcome'] as String? ?? 'Undetermined',
      confidenceScore: json['confidence_score'] as int? ?? 0,
      reasoning: json['reasoning'] as String? ?? 'No reasoning provided.',
    );
  }
}
