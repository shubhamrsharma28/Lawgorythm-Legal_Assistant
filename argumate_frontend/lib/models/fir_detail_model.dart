// lib/models/fir_detail_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'fir_data_model.dart'; // Import to use the IpcSection class

class FirDetailModel {
  final String id;
  final String filename;
  final Timestamp uploadedAt;
  final String simplifiedExplanation;
  final Map<String, dynamic> structuredSummary;
  final List<IpcSection> ipcSections;

  FirDetailModel({
    required this.id,
    required this.filename,
    required this.uploadedAt,
    required this.simplifiedExplanation,
    required this.structuredSummary,
    required this.ipcSections,
  });

  factory FirDetailModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Safely parse the IPC Sections
    var ipcList = data['ipc_sections'] as List? ?? [];
    List<IpcSection> sections = ipcList.map((i) => IpcSection.fromJson(i)).toList();

    return FirDetailModel(
      id: doc.id,
      filename: data['filename'] ?? 'Unnamed FIR',
      uploadedAt: data['uploaded_at'] ?? Timestamp.now(),
      simplifiedExplanation: data['simplified_explanation'] ?? 'No explanation available.',
      structuredSummary: data['structured_summary'] as Map<String, dynamic>? ?? {},
      ipcSections: sections,
    );
  }
}