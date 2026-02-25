// lib/models/argument_detail_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'argument_builder_model.dart'; // ArgumentPoint ke liye import

class ArgumentDetailModel {
  final String id;
  final String caseSummary;
  final Timestamp timestamp;
  final List<ArgumentPoint> prosecutionArguments;
  final List<ArgumentPoint> defenseArguments;

  ArgumentDetailModel({
    required this.id,
    required this.caseSummary,
    required this.timestamp,
    required this.prosecutionArguments,
    required this.defenseArguments,
  });

  factory ArgumentDetailModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Safely parse the arguments
    var prosecutionList = data['prosecution_arguments'] as List? ?? [];
    List<ArgumentPoint> prosecutionPoints = prosecutionList.map((i) => ArgumentPoint.fromJson(i)).toList();

    var defenseList = data['defense_arguments'] as List? ?? [];
    List<ArgumentPoint> defensePoints = defenseList.map((i) => ArgumentPoint.fromJson(i)).toList();

    return ArgumentDetailModel(
      id: doc.id,
      caseSummary: data['case_summary'] ?? 'No summary available.',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      prosecutionArguments: prosecutionPoints,
      defenseArguments: defensePoints,
    );
  }
}