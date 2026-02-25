    // lib/models/chat_list_model.dart
    import 'package:cloud_firestore/cloud_firestore.dart';

    class ChatListItem {
      final String id;
      final String userMessage;
      final String aiResponse;
      final Timestamp timestamp;

      ChatListItem({
        required this.id,
        required this.userMessage,
        required this.aiResponse,
        required this.timestamp,
      });

      factory ChatListItem.fromFirestore(DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ChatListItem(
          id: doc.id,
          userMessage: data['user_message'] ?? 'New Chat',
          aiResponse: data['ai_response'] ?? 'No response',
          timestamp: data['timestamp'] ?? Timestamp.now(),
        );
      }
    }
    