// lib/screens/prediction_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';

import '../services/prediction_service.dart';
import '../models/prediction_model.dart';

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  final TextEditingController _summaryController = TextEditingController();
  final Logger _logger = Logger();
  bool _isLoading = false;
  PredictionResponse? _predictionResponse;

  Future<void> _predictOutcome() async {
    final caseSummary = _summaryController.text.trim();
    if (caseSummary.length < 50) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a case summary of at least 50 characters.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _predictionResponse = null;
    });

    try {
      final service = Provider.of<PredictionService>(context, listen: false);
      final response = await service.predictOutcome(caseSummary);
      if (mounted) {
        setState(() {
          _predictionResponse = response;
        });
      }
    } catch (e) {
      _logger.e('Prediction Error: $e');
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
    _summaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Judgment Prediction'),
        backgroundColor: Colors.redAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Enter the facts of a case to get an AI-powered prediction of the likely judgment outcome.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _summaryController,
              decoration: const InputDecoration(
                labelText: 'Case Summary / Facts',
                hintText: 'e.g., "The prosecution presented two eyewitnesses who identified the accused..."',
                border: OutlineInputBorder(),
              ),
              maxLines: 10,
              minLines: 6,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _predictOutcome,
              icon: const Icon(Icons.online_prediction, color: Colors.white),
              label: Text(
                _isLoading ? 'Predicting...' : 'Predict Outcome',
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
            const SizedBox(height: 30),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
            if (_predictionResponse != null)
              _buildResultCard(_predictionResponse!),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(PredictionResponse response) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Prediction Report',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20),
            Center(
              child: Column(
                children: [
                  Text(
                    'Predicted Outcome:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    response.predictedOutcome,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Confidence: ${response.confidenceScore}%',
                     style: Theme.of(context).textTheme.titleLarge,
                  ),
                   const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: response.confidenceScore / 100,
                    minHeight: 8,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.redAccent),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Reasoning:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(response.reasoning),
          ],
        ),
      ),
    );
  }
}
