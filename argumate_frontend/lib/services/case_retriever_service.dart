// lib/services/case_retriever_service.dart
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../models/case_retriever_model.dart';

class CaseRetrieverService {
  final String _baseUrl = 'http://localhost:8000';
  final Logger _logger = Logger();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<CaseRetrieverResponse> findSimilarCases(String caseSummary) async {
    try {
      String? idToken = await _auth.currentUser?.getIdToken();
      if (idToken == null) {
        throw Exception('User not authenticated. Please log in.');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/cases/find-similar'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({'case_summary': caseSummary}),
      );

      if (response.statusCode == 200) {
        _logger.i('Similar cases retrieved successfully.');
        return CaseRetrieverResponse.fromJson(json.decode(response.body));
      } else {
        final errorData = json.decode(response.body);
        _logger.e('Case retrieval failed: ${errorData['detail']}');
        throw Exception('Failed to find similar cases: ${errorData['detail']}');
      }
    } catch (e) {
      _logger.e('Error finding similar cases: $e');
      rethrow;
    }
  }
}
