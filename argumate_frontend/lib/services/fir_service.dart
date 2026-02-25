// lib/services/fir_service.dart
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http_parser/http_parser.dart' show MediaType;

import '../models/fir_data_model.dart';

class FirService {
  final String _baseUrl = 'http://localhost:8000';
  final Logger _logger = Logger();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Function for explaining FIR from a file
  Future<FirData> explainFirFromFile({required PlatformFile platformFile}) async {
    try {
      String? idToken = await _auth.currentUser?.getIdToken();
      if (idToken == null) {
        throw Exception('User not authenticated. Please log in.');
      }

      var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/fir/explain'));
      request.headers['Authorization'] = 'Bearer $idToken';

      if (kIsWeb) {
        if (platformFile.bytes == null) throw Exception('File bytes are not available.');
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          platformFile.bytes!,
          filename: platformFile.name,
          contentType: MediaType('application', 'octet-stream'),
        ));
        _logger.i('Sending FIR file from bytes to backend: ${platformFile.name}');
      } else {
        if (platformFile.path == null) throw Exception('File path is not available.');
        request.files.add(await http.MultipartFile.fromPath(
          'file',
          platformFile.path!,
          filename: platformFile.name,
          contentType: MediaType('application', 'octet-stream'),
        ));
        _logger.i('Sending FIR file from path to backend: ${platformFile.path}');
      }

      return _sendRequestAndParseResponse(request);
    } catch (e) {
      _logger.e('Error explaining FIR from file: $e');
      rethrow;
    }
  }

  // --- NEW: Function for explaining FIR from text ---
  Future<FirData> explainFirFromText({required String firText}) async {
    try {
      String? idToken = await _auth.currentUser?.getIdToken();
      if (idToken == null) {
        throw Exception('User not authenticated. Please log in.');
      }

      var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/fir/explain'));
      request.headers['Authorization'] = 'Bearer $idToken';
      
      // Add the text as a form field
      request.fields['fir_text_input'] = firText;
      _logger.i('Sending FIR text to backend.');

      return _sendRequestAndParseResponse(request);
    } catch (e) {
      _logger.e('Error explaining FIR from text: $e');
      rethrow;
    }
  }

  // Helper function to avoid repeating code
  Future<FirData> _sendRequestAndParseResponse(http.MultipartRequest request) async {
    var response = await request.send();
    var responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      _logger.i('FIR explanation successful.');
      return FirData.fromJson(json.decode(responseBody));
    } else {
      _logger.e('FIR explanation failed with status ${response.statusCode}: $responseBody');
      throw Exception('Failed to explain FIR: ${json.decode(responseBody)['detail']}');
    }
  }
}
