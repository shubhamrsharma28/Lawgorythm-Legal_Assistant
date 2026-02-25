// lib/screens/case_timeline_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';

import '../services/case_timeline_service.dart';
import '../models/case_timeline_model.dart';

class CaseTimelineScreen extends StatefulWidget {
  const CaseTimelineScreen({super.key});

  @override
  State<CaseTimelineScreen> createState() => _CaseTimelineScreenState();
}

class _CaseTimelineScreenState extends State<CaseTimelineScreen> {
  final TextEditingController _summaryController = TextEditingController();
  final Logger _logger = Logger();
  bool _isLoading = false;
  CaseTimelineResponse? _timelineResponse;

  Future<void> _generateTimeline() async {
    final caseSummary = _summaryController.text.trim();
    if (caseSummary.length < 50) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a case summary of at least 50 characters.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _timelineResponse = null;
    });

    try {
      final service = Provider.of<CaseTimelineService>(context, listen: false);
      final response = await service.generateTimeline(caseSummary);
      if (mounted) {
        setState(() {
          _timelineResponse = response;
        });
      }
    } catch (e) {
      _logger.e('Timeline Generation Error: $e');
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
        title: const Text('Case Timeline'),
        backgroundColor: Colors.cyan,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Enter the facts of a case to generate a typical procedural timeline of the legal process in India.',
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
              onPressed: _isLoading ? null : _generateTimeline,
              icon: const Icon(Icons.timeline, color: Colors.white),
              label: Text(
                _isLoading ? 'Generating...' : 'Generate Timeline',
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
            const SizedBox(height: 30),

            if (_isLoading) const Center(child: CircularProgressIndicator()),

            if (_timelineResponse != null)
              _buildListView(_timelineResponse!.timelineSteps),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(List<TimelineStep> steps) {
    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        return _buildTimelineTile(
          step: step,
          isFirst: index == 0,
          isLast: index == steps.length - 1,
        );
      }),
    );
  }

  Widget _buildTimelineTile({required TimelineStep step, required bool isFirst, required bool isLast}) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(width: isFirst ? 0 : 2, height: 20, color: Colors.cyan),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.cyan, width: 2),
                ),
                child: const Icon(Icons.check_circle, color: Colors.cyan, size: 20),
              ),
              Expanded(child: Container(width: isLast ? 0 : 2, color: Colors.cyan)),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(step.stepTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(step.estimatedDateOrDuration, style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Text(step.description),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}