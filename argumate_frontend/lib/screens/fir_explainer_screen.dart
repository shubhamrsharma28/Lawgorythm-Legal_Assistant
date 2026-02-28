import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/fir_service.dart';
import '../models/fir_data_model.dart';

class FirExplainerScreen extends StatefulWidget {
  const FirExplainerScreen({super.key});
  @override
  State<FirExplainerScreen> createState() => _FirExplainerScreenState();
}

class _FirExplainerScreenState extends State<FirExplainerScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;
  FirData? _firData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  backgroundColor: const Color(0xFF0A0E21),
  appBar: AppBar(
    title: Text(
      'FIR Explainer',
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
            ElevatedButton.icon(onPressed: _isLoading ? null : _pick, icon: const Icon(Icons.upload_file), label: const Text('Upload FIR')),
            const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Text("OR", style: TextStyle(color: Colors.white54))),
            TextField(
              controller: _textController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Paste FIR Text', labelStyle: TextStyle(color: Colors.white70), enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24))),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _isLoading ? null : _explain, child: const Text('Simplify')),
            if (_firData != null) ...[
              const SizedBox(height: 24),
              _buildSection('Simplified Explanation', Text(_firData!.simplifiedExplanation, style: const TextStyle(color: Colors.white70))),
              const SizedBox(height: 16),
              _buildSection('Suggested IPC Sections', Column(children: _firData!.ipcSections.map((i) => ListTile(
                title: Text(i.section, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text(i.reason, style: const TextStyle(color: Colors.white54)),
                leading: const Icon(Icons.gavel, color: Colors.blueAccent),
              )).toList())),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 16)),
        const Divider(color: Colors.white10, height: 20),
        child,
      ]),
    );
  }

  Future<void> _pick() async {
    FilePickerResult? r = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'docx']);
    if (r != null) {
      setState(() => _isLoading = true);
      final res = await Provider.of<FirService>(context, listen: false).explainFirFromFile(platformFile: r.files.single);
      setState(() { _firData = res; _isLoading = false; });
    }
  }

  Future<void> _explain() async {
    setState(() => _isLoading = true);
    final res = await Provider.of<FirService>(context, listen: false).explainFirFromText(firText: _textController.text);
    setState(() { _firData = res; _isLoading = false; });
  }
}