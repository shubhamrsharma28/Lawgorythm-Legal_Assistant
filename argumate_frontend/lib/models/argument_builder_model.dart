// lib/models/argument_builder_model.dart

class ArgumentPoint {
  final String point;
  final String reasoning;

  ArgumentPoint({
    required this.point,
    required this.reasoning,
  });

  factory ArgumentPoint.fromJson(Map<String, dynamic> json) {
    return ArgumentPoint(
      point: json['point'] as String? ?? 'No point provided',
      reasoning: json['reasoning'] as String? ?? 'No reasoning provided.',
    );
  }
}

class ArgumentBuilderResponse {
  final String message;
  final List<ArgumentPoint> prosecutionArguments;
  final List<ArgumentPoint> defenseArguments;

  ArgumentBuilderResponse({
    required this.message,
    required this.prosecutionArguments,
    required this.defenseArguments,
  });

  factory ArgumentBuilderResponse.fromJson(Map<String, dynamic> json) {
    var prosecutionList = json['prosecution_arguments'] as List? ?? [];
    List<ArgumentPoint> prosecutionPoints = prosecutionList.map((i) => ArgumentPoint.fromJson(i)).toList();

    var defenseList = json['defense_arguments'] as List? ?? [];
    List<ArgumentPoint> defensePoints = defenseList.map((i) => ArgumentPoint.fromJson(i)).toList();

    return ArgumentBuilderResponse(
      message: json['message'] as String? ?? 'Arguments generated.',
      prosecutionArguments: prosecutionPoints,
      defenseArguments: defensePoints,
    );
  }
}
