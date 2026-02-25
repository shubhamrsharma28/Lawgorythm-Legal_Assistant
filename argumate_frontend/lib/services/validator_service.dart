// lib/services/validator_service.dart
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../models/fir_validator_model.dart';

class ValidatorService {
  final String _baseUrl = 'http://localhost:8000';
  final Logger _logger = Logger();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<FirValidationResponse> validateFirDraft(String draftText) async {
    try {
      String? idToken = await _auth.currentUser?.getIdToken();
      if (idToken == null) {
        throw Exception('User not authenticated. Please log in.');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/fir-validator/validate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({'fir_draft_text': draftText}),
      );

      if (response.statusCode == 200) {
        _logger.i('FIR draft validation successful.');
        return FirValidationResponse.fromJson(json.decode(response.body));
      } else {
        final errorData = json.decode(response.body);
        _logger.e('FIR draft validation failed: ${errorData['detail']}');
        throw Exception('Failed to validate FIR draft: ${errorData['detail']}');
      }
    } catch (e) {
      _logger.e('Error validating FIR draft: $e');
      rethrow;
    }
  }
}
