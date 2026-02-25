// lib/models/fir_data_model.dart

// --- NEW: A class to hold IPC Section data ---
class IpcSection {
  final String section;
  final String reason;

  IpcSection({required this.section, required this.reason});

  factory IpcSection.fromJson(Map<String, dynamic> json) {
    return IpcSection(
      section: json['section'] as String? ?? 'N/A',
      reason: json['reason'] as String? ?? 'No reason provided.',
    );
  }
}

class FirData {
  final String message;
  final String simplifiedExplanation;
  final Map<String, dynamic> structuredSummary;
  final String firId;
  final List<IpcSection> ipcSections; // <-- ADDED THIS FIELD

  FirData({
    required this.message,
    required this.simplifiedExplanation,
    required this.structuredSummary,
    required this.firId,
    required this.ipcSections, // <-- ADDED TO CONSTRUCTOR
  });

  factory FirData.fromJson(Map<String, dynamic> json) {
    // Parse the list of IPC sections from the backend response
    var ipcList = json['ipc_sections'] as List? ?? [];
    List<IpcSection> sections = ipcList.map((i) => IpcSection.fromJson(i)).toList();

    return FirData(
      message: json['message'] as String,
      simplifiedExplanation: json['simplified_explanation'] as String,
      structuredSummary: json['structured_summary'] as Map<String, dynamic>,
      firId: json['fir_id'] as String,
      ipcSections: sections, // <-- PARSED LIST IS ASSIGNED HERE
    );
  }
}
