import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/argument_builder_service.dart';
import '../models/argument_builder_model.dart';

class ArgumentBuilderScreen extends StatefulWidget {
  const ArgumentBuilderScreen({super.key});
  @override
  State<ArgumentBuilderScreen> createState() => _ArgumentBuilderScreenState();
}

class _ArgumentBuilderScreenState extends State<ArgumentBuilderScreen> {
  final TextEditingController _summaryController = TextEditingController();
  bool _isLoading = false;
  ArgumentBuilderResponse? _argumentResponse;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  backgroundColor: const Color(0xFF0A0E21), // Dashboard Blue BG
  appBar: AppBar(
    title: Text(
      'Legal Argument Builder', 
      style: GoogleFonts.audiowide(
        textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 22, 
          fontWeight: FontWeight.w500,
          letterSpacing: 1.2,
        ),
      ),
    ),
    backgroundColor: const Color(0xFF1A237E),
    elevation: 10, // Thoda shadow ke liye
    iconTheme: const IconThemeData(color: Colors.white),
  ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('AI will generate arguments for Prosecution and Defense.', 
              textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 20),
            TextField(
              controller: _summaryController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Case Summary here',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
              ),
              maxLines: 6,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _buildArguments,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
              child: Text(_isLoading ? 'Processing...' : 'Build Arguments', style: const TextStyle(color: Colors.white)),
            ),
            if (_isLoading) const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator())),
            if (_argumentResponse != null) ...[
               _buildSection('Prosecution Arguments', _argumentResponse!.prosecutionArguments, Icons.gavel, Colors.redAccent),
               const SizedBox(height: 20),
               _buildSection('Defense Arguments', _argumentResponse!.defenseArguments, Icons.shield, Colors.greenAccent),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<ArgumentPoint> args, IconData icon, Color accent) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(icon, color: accent), const SizedBox(width: 8), Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))]),
        const Divider(color: Colors.white10, height: 25),
        ...args.map((a) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(a.point, style: TextStyle(color: accent, fontWeight: FontWeight.bold)),
          Text(a.reasoning, style: const TextStyle(color: Colors.white70)),
        ]))),
      ]),
    );
  }

  Future<void> _buildArguments() async {
    setState(() => _isLoading = true);
    final res = await Provider.of<ArgumentBuilderService>(context, listen: false).buildArguments(_summaryController.text);
    setState(() { _argumentResponse = res; _isLoading = false; });
  }
}