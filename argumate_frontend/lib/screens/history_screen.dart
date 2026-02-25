// lib/screens/history_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // For date formatting, need to add this dependency

import '../services/history_service.dart';
import '../models/fir_list_model.dart';
import '../models/chat_list_model.dart';
import 'chat_detail_screen.dart';
import 'fir_detail_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Saved History'),
          backgroundColor: Colors.indigo,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'FIR Explanations', icon: Icon(Icons.description)),
              Tab(text: 'Chat History', icon: Icon(Icons.chat)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_FirHistoryList(), _ChatHistoryList()],
        ),
      ),
    );
  }
}

class _FirHistoryList extends StatelessWidget {
  const _FirHistoryList();

  @override
  Widget build(BuildContext context) {
    final historyService = Provider.of<HistoryService>(context);

    return StreamBuilder<List<FirListItem>>(
      stream: historyService.getFirHistory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No FIR history found.'));
        }

        final firs = snapshot.data!;
        return ListView.builder(
          itemCount: firs.length,
          itemBuilder: (context, index) {
            final fir = firs[index];
            final formattedDate = DateFormat(
              'yyyy-MM-dd HH:mm',
            ).format(fir.uploadedAt.toDate());
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.description, color: Colors.green),
                title: Text(fir.filename),
                subtitle: Text('Uploaded: $formattedDate'),
                // Add onPressed for viewing full details later
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FirDetailScreen(firId: fir.id),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _ChatHistoryList extends StatelessWidget {
  const _ChatHistoryList();

  @override
  Widget build(BuildContext context) {
    final historyService = Provider.of<HistoryService>(context);

    return StreamBuilder<List<ChatListItem>>(
      stream: historyService.getChatHistory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No chat history found.'));
        }

        final chats = snapshot.data!;
        return ListView.builder(
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final chat = chats[index];
            final formattedDate = DateFormat(
              'yyyy-MM-dd HH:mm',
            ).format(chat.timestamp.toDate());
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.chat_bubble, color: Colors.orange),
                title: Text(
                  chat.userMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text('Date: $formattedDate'),
                // Add onPressed for viewing full chat session later
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ChatDetailScreen(
                            chatId: chat.id,
                          ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
