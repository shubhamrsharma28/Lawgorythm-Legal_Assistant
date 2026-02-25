// lib/services/argument_builder_service.dart
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../models/argument_builder_model.dart';

class ArgumentBuilderService {
  final String _baseUrl = 'http://localhost:8000';
  final Logger _logger = Logger();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<ArgumentBuilderResponse> buildArguments(String caseSummary) async {
    try {
      String? idToken = await _auth.currentUser?.getIdToken();
      if (idToken == null) {
        throw Exception('User not authenticated. Please log in.');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/arguments/build'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({'case_summary': caseSummary}),
      );

      if (response.statusCode == 200) {
        _logger.i('Arguments built successfully.');
        return ArgumentBuilderResponse.fromJson(json.decode(response.body));
      } else {
        final errorData = json.decode(response.body);
        _logger.e('Argument building failed: ${errorData['detail']}');
        throw Exception('Failed to build arguments: ${errorData['detail']}');
      }
    } catch (e) {
      _logger.e('Error building arguments: $e');
      rethrow;
    }
  }
}
