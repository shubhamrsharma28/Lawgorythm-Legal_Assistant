// lib/services/case_timeline_service.dart
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../models/case_timeline_model.dart';

class CaseTimelineService {
  final String _baseUrl = 'http://localhost:8000';
  final Logger _logger = Logger();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<CaseTimelineResponse> generateTimeline(String caseSummary) async {
    try {
      String? idToken = await _auth.currentUser?.getIdToken();
      if (idToken == null) {
        throw Exception('User not authenticated. Please log in.');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/timeline/generate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({'case_summary': caseSummary}),
      );

      if (response.statusCode == 200) {
        _logger.i('Case timeline generated successfully.');
        return CaseTimelineResponse.fromJson(json.decode(response.body));
      } else {
        final errorData = json.decode(response.body);
        _logger.e('Timeline generation failed: ${errorData['detail']}');
        throw Exception('Failed to generate timeline: ${errorData['detail']}');
      }
    } catch (e) {
      _logger.e('Error generating timeline: $e');
      rethrow;
    }
  }
}
