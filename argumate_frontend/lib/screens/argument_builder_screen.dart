// lib/screens/argument_builder_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';

import '../services/argument_builder_service.dart';
import '../models/argument_builder_model.dart';

class ArgumentBuilderScreen extends StatefulWidget {
  const ArgumentBuilderScreen({super.key});

  @override
  State<ArgumentBuilderScreen> createState() => _ArgumentBuilderScreenState();
}

class _ArgumentBuilderScreenState extends State<ArgumentBuilderScreen> {
  final TextEditingController _summaryController = TextEditingController();
  final Logger _logger = Logger();
  bool _isLoading = false;
  ArgumentBuilderResponse? _argumentResponse;

  Future<void> _buildArguments() async {
    final caseSummary = _summaryController.text.trim();
    if (caseSummary.length < 50) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a case summary of at least 50 characters.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _argumentResponse = null;
    });

    try {
      final service = Provider.of<ArgumentBuilderService>(context, listen: false);
      final response = await service.buildArguments(caseSummary);
      if (mounted) {
        setState(() {
          _argumentResponse = response;
        });
      }
    } catch (e) {
      _logger.e('Argument Builder Error: $e');
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
        title: const Text('Legal Argument Builder'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Enter the facts or summary of a case below. The AI will generate potential arguments for both the prosecution and defense.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _summaryController,
              decoration: const InputDecoration(
                labelText: 'Case Summary / Facts',
                hintText: 'e.g., "John Doe reported that Jane Smith stole his bicycle..."',
                border: OutlineInputBorder(),
              ),
              maxLines: 10,
              minLines: 6,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _buildArguments,
              icon: const Icon(Icons.construction, color: Colors.white),
              label: Text(
                _isLoading ? 'Generating...' : 'Build Arguments',
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
            const SizedBox(height: 30),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
            if (_argumentResponse != null)
              _buildResults(_argumentResponse!),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(ArgumentBuilderResponse response) {
    return Column(
      children: [
        _buildArgumentSection(
          title: 'Prosecution Arguments',
          arguments: response.prosecutionArguments,
          icon: Icons.gavel,
          color: Colors.red.shade700,
        ),
        const SizedBox(height: 20),
        _buildArgumentSection(
          title: 'Defense Arguments',
          arguments: response.defenseArguments,
          icon: Icons.shield,
          color: Colors.blue.shade700,
        ),
      ],
    );
  }

  Widget _buildArgumentSection({
    required String title,
    required List<ArgumentPoint> arguments,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 20),
            ...arguments.map((arg) => Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Point: ${arg.point}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Reasoning: ${arg.reasoning}'),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
