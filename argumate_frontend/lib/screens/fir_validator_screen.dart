import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/validator_service.dart';
import '../models/fir_validator_model.dart';

class FirValidatorScreen extends StatefulWidget {
  const FirValidatorScreen({super.key});
  @override
  State<FirValidatorScreen> createState() => _FirValidatorScreenState();
}

class _FirValidatorScreenState extends State<FirValidatorScreen> {
  final TextEditingController _draftController = TextEditingController();
  bool _isLoading = false;
  FirValidationResponse? _response;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  backgroundColor: const Color(0xFF0A0E21),
  appBar: AppBar(
    title: Text(
      'FIR Draft Validator',
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
              controller: _draftController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Enter FIR Draft', labelStyle: TextStyle(color: Colors.white70), enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24))),
              maxLines: 8,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _isLoading ? null : _validate, child: const Text('Validate Draft')),
            if (_response != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
                child: Column(children: [
                  const Text('Overall Score', style: TextStyle(color: Colors.white70)),
                  Text('${_response!.overallScore}%', style: const TextStyle(color: Colors.blueAccent, fontSize: 32, fontWeight: FontWeight.bold)),
                  LinearProgressIndicator(value: _response!.overallScore / 100, backgroundColor: Colors.white10, color: Colors.blueAccent),
                ]),
              ),
              const SizedBox(height: 20),
              ..._response!.validationPoints.map((p) => ListTile(
                leading: Icon(Icons.info_outline, color: p.severity == 'High' ? Colors.redAccent : Colors.white70),
                title: Text(p.issue, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text(p.suggestion, style: const TextStyle(color: Colors.white54)),
              )),
            ]
          ],
        ),
      ),
    );
  }

  Future<void> _validate() async {
    setState(() => _isLoading = true);
    final res = await Provider.of<ValidatorService>(context, listen: false).validateFirDraft(_draftController.text);
    setState(() { _response = res; _isLoading = false; });
  }
}