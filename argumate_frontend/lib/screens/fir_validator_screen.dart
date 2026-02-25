// lib/screens/fir_validator_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';

import '../services/validator_service.dart';
import '../models/fir_validator_model.dart';

class FirValidatorScreen extends StatefulWidget {
  const FirValidatorScreen({super.key});

  @override
  State<FirValidatorScreen> createState() => _FirValidatorScreenState();
}

class _FirValidatorScreenState extends State<FirValidatorScreen> {
  final TextEditingController _draftController = TextEditingController();
  final Logger _logger = Logger();
  bool _isLoading = false;
  FirValidationResponse? _validationResponse;

  Future<void> _validateDraft() async {
    final draftText = _draftController.text.trim();
    if (draftText.length < 50) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter at least 50 characters to validate.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _validationResponse = null;
    });

    try {
      final validatorService = Provider.of<ValidatorService>(context, listen: false);
      final response = await validatorService.validateFirDraft(draftText);
      if (mounted) {
        setState(() {
          _validationResponse = response;
        });
      }
    } catch (e) {
      _logger.e('FIR Validation Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _draftController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FIR Draft Validator'),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Enter your FIR draft below to get an AI-powered analysis and suggestions for improvement.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _draftController,
              decoration: const InputDecoration(
                labelText: 'Paste FIR Draft Here',
                hintText: 'Type or paste the full text of your FIR draft...',
                border: OutlineInputBorder(),
              ),
              maxLines: 12,
              minLines: 8,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _validateDraft,
              icon: const Icon(Icons.check_circle_outline, color: Colors.white),
              label: Text(
                _isLoading ? 'Analyzing...' : 'Validate Draft',
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
            const SizedBox(height: 30),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
            if (_validationResponse != null)
              _buildValidationResult(_validationResponse!),
          ],
        ),
      ),
    );
  }

  Widget _buildValidationResult(FirValidationResponse response) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Validation Report',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20),
            Center(
              child: Column(
                children: [
                  Text(
                    'Overall Score: ${response.overallScore}/100',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: response.overallScore > 75 ? Colors.green : (response.overallScore > 50 ? Colors.orange : Colors.red),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: response.overallScore / 100,
                    minHeight: 10,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      response.overallScore > 75 ? Colors.green : (response.overallScore > 50 ? Colors.orange : Colors.red),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ...response.validationPoints.map((point) => _buildValidationPoint(point)),
          ],
        ),
      ),
    );
  }

  Widget _buildValidationPoint(ValidationPoint point) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                point.severity == 'High' ? Icons.error : (point.severity == 'Medium' ? Icons.warning : Icons.info),
                color: point.severity == 'High' ? Colors.red : (point.severity == 'Medium' ? Colors.orange : Colors.blue),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  point.issue,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 32.0), // Indent suggestion
            child: Text(point.suggestion),
          ),
        ],
      ),
    );
  }
}
