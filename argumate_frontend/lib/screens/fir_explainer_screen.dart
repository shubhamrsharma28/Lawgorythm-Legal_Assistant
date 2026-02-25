// lib/screens/fir_explainer_screen.dart
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../services/fir_service.dart';
import '../models/fir_data_model.dart';

class FirExplainerScreen extends StatefulWidget {
  const FirExplainerScreen({super.key});

  @override
  State<FirExplainerScreen> createState() => _FirExplainerScreenState();
}

class _FirExplainerScreenState extends State<FirExplainerScreen> {
  final Logger _logger = Logger();
  final TextEditingController _textController = TextEditingController(); // Controller for text input
  bool _isLoading = false;
  FirData? _firData;
  String? _selectedFileName;

  // --- UPDATED: Logic for handling file picking ---
  Future<void> _pickAndExplainFir() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx'],
      );
      if (result != null && result.files.single.name.isNotEmpty) {
        PlatformFile platformFile = result.files.single;
        setState(() {
          _selectedFileName = platformFile.name;
          _textController.clear(); // Clear text field if file is selected
        });
        final firService = Provider.of<FirService>(context, listen: false);
        _processRequest(() => firService.explainFirFromFile(platformFile: platformFile));
      } else {
        _logger.i('File picking cancelled by user.');
      }
    } catch (e) {
      _handleError(e, "File picking failed");
    }
  }

  // --- NEW: Logic for handling text input ---
  void _explainFirFromText() {
    final text = _textController.text.trim();
    if (text.length < 50) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter at least 50 characters.')),
      );
      return;
    }
    setState(() {
      _selectedFileName = null; // Clear file name if text is used
    });
    final firService = Provider.of<FirService>(context, listen: false);
    _processRequest(() => firService.explainFirFromText(firText: text));
  }

  // --- NEW: Centralized request processing logic ---
  Future<void> _processRequest(Future<FirData> Function() apiCall) async {
    setState(() {
      _isLoading = true;
      _firData = null;
    });
    try {
      final explainedData = await apiCall();
      if (!mounted) return;
      setState(() {
        _firData = explainedData;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('FIR Processed Successfully!')),
      );
    } catch (e) {
      _handleError(e, "FIR explanation process failed");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // --- UPDATED: Helper to show errors ---
  // The String parameter 'context' has been renamed to 'contextMessage' to avoid conflict.
  void _handleError(Object e, String contextMessage) {
    _logger.e('$contextMessage: $e');
    if (mounted) {
      // Now, 'context' correctly refers to the BuildContext of the widget.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FIR Explainer'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- UI for File Upload ---
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _pickAndExplainFir,
              icon: const Icon(Icons.upload_file, color: Colors.white),
              label: const Text('Upload FIR (PDF/DOCX)', style: TextStyle(fontSize: 18, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              ),
            ),
            if (_selectedFileName != null) ...[
              const SizedBox(height: 10),
              Text('Selected File: $_selectedFileName', textAlign: TextAlign.center, style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[700])),
            ],
            
            // --- Divider ---
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Row(children: [
                Expanded(child: Divider()),
                Padding(padding: EdgeInsets.symmetric(horizontal: 8.0), child: Text("OR")),
                Expanded(child: Divider()),
              ]),
            ),

            // --- NEW: UI for Text Input ---
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                labelText: 'Paste FIR Text Here',
                hintText: 'Type or paste the full text of the FIR...',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _textController.clear(),
                ),
              ),
              maxLines: 8,
              minLines: 5,
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _explainFirFromText,
              icon: const Icon(Icons.text_fields, color: Colors.white),
              label: const Text('Explain Text', style: TextStyle(fontSize: 18, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              ),
            ),
            
            const SizedBox(height: 30),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
            if (_firData != null) ...[
              _buildInfoCard(
                title: 'Simplified Explanation',
                child: Text(_firData!.simplifiedExplanation, style: const TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 20),
              _buildInfoCard(
                title: 'Structured Summary',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _firData!.structuredSummary.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: RichText(
                        text: TextSpan(
                          style: DefaultTextStyle.of(context).style,
                          children: <TextSpan>[
                            TextSpan(text: '${entry.key.replaceAll('_', ' ').toTitleCase()}: ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            TextSpan(text: '${entry.value}', style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              if (_firData!.ipcSections.isNotEmpty)
                _buildInfoCard(
                  title: 'Suggested IPC Sections',
                  child: Column(
                    children: _firData!.ipcSections.map((ipc) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.gavel, color: Colors.deepOrange),
                        title: Text(ipc.section, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(ipc.reason),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required Widget child}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
            const Divider(height: 20, thickness: 1),
            child,
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String toTitleCase() {
    return replaceAll(RegExp(r'_'), ' ').split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}
