// lib/services/chat_service.dart
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:firebase_auth/firebase_auth.dart'; // To get ID token
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

class ChatService {
  final String _baseUrl = 'http://localhost:8000';
  final Logger _logger = Logger();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> sendChatMessage({required String message}) async {
    try {
      String? idToken = await _auth.currentUser?.getIdToken();
      if (idToken == null) {
        throw Exception('User not authenticated. Please log in.');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/'), // <-- ADDED TRAILING SLASH
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({'message': message}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['ai_response'] as String;
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception('Failed to get chat response: ${errorData['detail']}');
      }
    } catch (e) {
      _logger.e('Error sending chat message: $e');
      rethrow;
    }
  }
}
