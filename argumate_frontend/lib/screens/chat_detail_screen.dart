// lib/screens/chat_detail_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chat_message_model.dart';
import '../models/chat_list_model.dart';
import '../services/auth_service.dart';
import 'chatbot_screen.dart'; // For ChatBubble

class ChatDetailScreen extends StatelessWidget {
  final String chatId;

  const ChatDetailScreen({super.key, required this.chatId});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context, listen: false).getCurrentUser();

    if (user == null) {
      return const Scaffold(body: Center(child: Text("User not logged in.")));
    }

    // Firestore se data fetch karne ke liye FutureBuilder ka istemal karein
    final chatDocFuture = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('chat_history')
        .doc(chatId)
        .get();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Details'),
        backgroundColor: Colors.indigo,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: chatDocFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Chat not found."));
          }

          // Data ko model mein convert karein
          final chatItem = ChatListItem.fromFirestore(snapshot.data!);

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                ChatBubble(
                  message: ChatMessage(
                    text: chatItem.userMessage,
                    sender: MessageSender.user,
                  ),
                ),
                ChatBubble(
                  message: ChatMessage(
                    text: chatItem.aiResponse,
                    sender: MessageSender.ai,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}