import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/case_retriever_service.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/case_retriever_model.dart';

class CaseRetrieverScreen extends StatefulWidget {
  const CaseRetrieverScreen({super.key});
  @override
  State<CaseRetrieverScreen> createState() => _CaseRetrieverScreenState();
}

class _CaseRetrieverScreenState extends State<CaseRetrieverScreen> {
  final TextEditingController _summaryController = TextEditingController();
  bool _isLoading = false;
  CaseRetrieverResponse? _caseResponse;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  backgroundColor: const Color(0xFF0A0E21),
  appBar: AppBar(
    title: Text(
      'Case Law Retriever',
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
              decoration: const InputDecoration(
                labelText: 'Case Facts',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _findCases,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
              child: const Text('Search Citations', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 24),
            if (_caseResponse != null) ..._caseResponse!.similarCases.map((c) => _buildCard(c)),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(SimilarCase c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(c.caseName, style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(c.citation, style: const TextStyle(color: Colors.white54, fontStyle: FontStyle.italic)),
        const Divider(color: Colors.white10, height: 20),
        Text('Summary: ${c.summary}', style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 8),
        Text('Relevance: ${c.relevance}', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w500)),
      ]),
    );
  }

  Future<void> _findCases() async {
    setState(() => _isLoading = true);
    final res = await Provider.of<CaseRetrieverService>(context, listen: false).findSimilarCases(_summaryController.text);
    setState(() { _caseResponse = res; _isLoading = false; });
  }
}