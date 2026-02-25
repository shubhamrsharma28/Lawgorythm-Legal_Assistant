// lib/services/prediction_service.dart
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../models/prediction_model.dart';

class PredictionService {
  final String _baseUrl = 'http://localhost:8000';
  final Logger _logger = Logger();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<PredictionResponse> predictOutcome(String caseSummary) async {
    try {
      String? idToken = await _auth.currentUser?.getIdToken();
      if (idToken == null) {
        throw Exception('User not authenticated. Please log in.');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/predict/outcome'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({'case_summary': caseSummary}),
      );

      if (response.statusCode == 200) {
        _logger.i('Prediction generated successfully.');
        return PredictionResponse.fromJson(json.decode(response.body));
      } else {
        final errorData = json.decode(response.body);
        _logger.e('Prediction failed: ${errorData['detail']}');
        throw Exception('Failed to predict outcome: ${errorData['detail']}');
      }
    } catch (e) {
      _logger.e('Error predicting outcome: $e');
      rethrow;
    }
  }
}
