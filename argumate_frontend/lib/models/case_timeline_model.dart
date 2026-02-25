// lib/models/case_timeline_model.dart

class TimelineStep {
  final String stepTitle;
  final String description;
  final String estimatedDateOrDuration;

  TimelineStep({
    required this.stepTitle,
    required this.description,
    required this.estimatedDateOrDuration,
  });

  factory TimelineStep.fromJson(Map<String, dynamic> json) {
    return TimelineStep(
      stepTitle: json['step_title'] as String? ?? 'Unnamed Step',
      description: json['description'] as String? ?? 'No description available.',
      estimatedDateOrDuration: json['estimated_date_or_duration'] as String? ?? 'N/A',
    );
  }
}

class CaseTimelineResponse {
  final String message;
  final List<TimelineStep> timelineSteps;

  CaseTimelineResponse({
    required this.message,
    required this.timelineSteps,
  });

  factory CaseTimelineResponse.fromJson(Map<String, dynamic> json) {
    var stepList = json['timeline_steps'] as List? ?? [];
    List<TimelineStep> steps = stepList.map((i) => TimelineStep.fromJson(i)).toList();

    return CaseTimelineResponse(
      message: json['message'] as String? ?? 'Timeline generated.',
      timelineSteps: steps,
    );
  }
}
