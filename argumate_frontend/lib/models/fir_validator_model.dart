// lib/models/fir_validator_model.dart

class ValidationPoint {
  final String issue;
  final String suggestion;
  final String severity;

  ValidationPoint({
    required this.issue,
    required this.suggestion,
    required this.severity,
  });

  factory ValidationPoint.fromJson(Map<String, dynamic> json) {
    return ValidationPoint(
      issue: json['issue'] as String? ?? 'Unknown Issue',
      suggestion: json['suggestion'] as String? ?? 'No suggestion provided.',
      severity: json['severity'] as String? ?? 'Low',
    );
  }
}

class FirValidationResponse {
  final String message;
  final int overallScore;
  final List<ValidationPoint> validationPoints;

  FirValidationResponse({
    required this.message,
    required this.overallScore,
    required this.validationPoints,
  });

  factory FirValidationResponse.fromJson(Map<String, dynamic> json) {
    var pointsList = json['validation_points'] as List? ?? [];
    List<ValidationPoint> points = pointsList.map((i) => ValidationPoint.fromJson(i)).toList();

    return FirValidationResponse(
      message: json['message'] as String? ?? 'Validation complete.',
      overallScore: json['overall_score'] as int? ?? 0,
      validationPoints: points,
    );
  }
}
