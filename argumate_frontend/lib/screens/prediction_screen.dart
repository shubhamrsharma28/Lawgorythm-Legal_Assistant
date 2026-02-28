import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/prediction_service.dart';
import '../models/prediction_model.dart';
import 'package:google_fonts/google_fonts.dart';

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});
  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  final TextEditingController _summaryController = TextEditingController();
  bool _isLoading = false;
  PredictionResponse? _prediction;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  backgroundColor: const Color(0xFF0A0E21),
  appBar: AppBar(
    title: Text(
      'Judgment Prediction',
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
              decoration: const InputDecoration(labelText: 'Case Summary', labelStyle: TextStyle(color: Colors.white70), enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24))),
              maxLines: 6,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _isLoading ? null : _predict, child: const Text('Predict Outcome')),
            if (_prediction != null) ...[
              const SizedBox(height: 30),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
                child: Column(children: [
                  const Text('PREDICTED OUTCOME', style: TextStyle(color: Colors.white54, letterSpacing: 1.5)),
                  const SizedBox(height: 10),
                  Text(_prediction!.predictedOutcome.toUpperCase(), style: const TextStyle(color: Colors.redAccent, fontSize: 28, fontWeight: FontWeight.bold)),
                  const Divider(color: Colors.white10, height: 40),
                  _row('Confidence Score', '${_prediction!.confidenceScore}%'),
                  const SizedBox(height: 20),
                  const Align(alignment: Alignment.centerLeft, child: Text('AI REASONING:', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold))),
                  const SizedBox(height: 8),
                  Text(_prediction!.reasoning, style: const TextStyle(color: Colors.white70, height: 1.5)),
                ]),
              )
            ]
          ],
        ),
      ),
    );
  }

  Widget _row(String l, String v) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: const TextStyle(color: Colors.white70)), Text(v, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]);

  Future<void> _predict() async {
    setState(() => _isLoading = true);
    final res = await Provider.of<PredictionService>(context, listen: false).predictOutcome(_summaryController.text);
    setState(() { _prediction = res; _isLoading = false; });
  }
}