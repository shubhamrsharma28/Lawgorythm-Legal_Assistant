import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/case_timeline_service.dart';
import '../models/case_timeline_model.dart';

class CaseTimelineScreen extends StatefulWidget {
  const CaseTimelineScreen({super.key});
  @override
  State<CaseTimelineScreen> createState() => _CaseTimelineScreenState();
}

class _CaseTimelineScreenState extends State<CaseTimelineScreen> {
  final TextEditingController _summaryController = TextEditingController();
  bool _isLoading = false;
  CaseTimelineResponse? _timelineResponse;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  backgroundColor: const Color(0xFF0A0E21),
  appBar: AppBar(
    title: Text(
      'Case Timeline',
      style: GoogleFonts.audiowide(
        textStyle: const TextStyle(color: Colors.white, fontSize: 20, letterSpacing: 1.2),
      ),
    ),
    backgroundColor: const Color(0xFF1A237E),
    iconTheme: const IconThemeData(color: Colors.white),
  ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _summaryController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Case Facts', labelStyle: TextStyle(color: Colors.white70), enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24))),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _isLoading ? null : _generate, child: Text(_isLoading ? 'Generating...' : 'Predict Timeline')),
            const SizedBox(height: 24),
            if (_timelineResponse != null) ...List.generate(_timelineResponse!.timelineSteps.length, (i) => _buildStep(_timelineResponse!.timelineSteps[i], i == 0)),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(TimelineStep step, bool isFirst) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Column(children: [
        Container(width: 2, height: 20, color: isFirst ? Colors.transparent : Colors.blueAccent),
        const Icon(Icons.circle, size: 16, color: Colors.blueAccent),
        Container(width: 2, height: 80, color: Colors.blueAccent),
      ]),
      const SizedBox(width: 16),
      Expanded(child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white10)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(step.stepTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Text(step.estimatedDateOrDuration, style: const TextStyle(color: Colors.blueAccent, fontSize: 12)),
          const SizedBox(height: 4),
          Text(step.description, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        ]),
      )),
    ]);
  }

  Future<void> _generate() async {
    setState(() => _isLoading = true);
    final res = await Provider.of<CaseTimelineService>(context, listen: false).generateTimeline(_summaryController.text);
    setState(() { _timelineResponse = res; _isLoading = false; });
  }
}