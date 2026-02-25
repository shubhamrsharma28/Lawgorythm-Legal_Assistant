    // lib/models/fir_list_model.dart
    import 'package:cloud_firestore/cloud_firestore.dart';

    class FirListItem {
      final String id;
      final String filename;
      final Timestamp uploadedAt;

      FirListItem({
        required this.id,
        required this.filename,
        required this.uploadedAt,
      });

      factory FirListItem.fromFirestore(DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        return FirListItem(
          id: doc.id,
          filename: data['filename'] ?? 'Unnamed FIR',
          uploadedAt: data['uploaded_at'] ?? Timestamp.now(),
        );
      }
    }
    