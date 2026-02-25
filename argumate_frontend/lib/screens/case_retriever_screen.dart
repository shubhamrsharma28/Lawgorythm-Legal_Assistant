// lib/screens/case_retriever_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';

import '../services/case_retriever_service.dart';
import '../models/case_retriever_model.dart';

class CaseRetrieverScreen extends StatefulWidget {
  const CaseRetrieverScreen({super.key});

  @override
  State<CaseRetrieverScreen> createState() => _CaseRetrieverScreenState();
}

class _CaseRetrieverScreenState extends State<CaseRetrieverScreen> {
  final TextEditingController _summaryController = TextEditingController();
  final Logger _logger = Logger();
  bool _isLoading = false;
  CaseRetrieverResponse? _caseResponse;

  Future<void> _findCases() async {
    final caseSummary = _summaryController.text.trim();
    if (caseSummary.length < 50) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a case summary of at least 50 characters.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _caseResponse = null;
    });

    try {
      final service = Provider.of<CaseRetrieverService>(context, listen: false);
      final response = await service.findSimilarCases(caseSummary);
      if (mounted) {
        setState(() {
          _caseResponse = response;
        });
      }
    } catch (e) {
      _logger.e('Case Retriever Error: $e');
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
        title: const Text('Case Law Retriever'),
        backgroundColor: Colors.brown,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Enter the facts of a case to find similar, real-life case laws with citations from India.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _summaryController,
              decoration: const InputDecoration(
                labelText: 'Case Summary / Facts',
                hintText: 'e.g., "A verbal dispute over property led to a physical altercation..."',
                border: OutlineInputBorder(),
              ),
              maxLines: 10,
              minLines: 6,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _findCases,
              icon: const Icon(Icons.search, color: Colors.white),
              label: Text(
                _isLoading ? 'Searching...' : 'Find Similar Cases',
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
            const SizedBox(height: 30),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
            if (_caseResponse != null)
              _buildResults(_caseResponse!),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(CaseRetrieverResponse response) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Found ${response.similarCases.length} Relevant Cases',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ...response.similarCases.map((caseItem) => _buildCaseCard(caseItem)),
      ],
    );
  }

  Widget _buildCaseCard(SimilarCase caseItem) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              caseItem.caseName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 4),
            Text(
              caseItem.citation,
              style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),
            const Divider(height: 20),
            _buildDetailRow(Icons.summarize, 'Summary', caseItem.summary),
            const SizedBox(height: 12),
            _buildDetailRow(Icons.link, 'Relevance', caseItem.relevance),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.brown),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(content),
            ],
          ),
        ),
      ],
    );
  }
}
