// lib/screens/chatbot_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import 'dart:ui'; // For BackdropFilter (Glass effect)

import '../services/chat_service.dart';
import '../models/chat_message_model.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final Logger _logger = Logger();
  bool _isSending = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _messages.add(ChatMessage(
      text: 'Hi! I am ArguMate, your AI legal assistant. How can I help you today?',
      sender: MessageSender.ai,
    ));
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text.trim();
    setState(() {
      _messages.add(ChatMessage(text: userMessage, sender: MessageSender.user));
      _messageController.clear();
      _isSending = true;
    });
    _scrollToBottom();

    try {
      final chatService = Provider.of<ChatService>(context, listen: false);
      final aiResponse = await chatService.sendChatMessage(message: userMessage);

      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(text: aiResponse, sender: MessageSender.ai));
      });
      _scrollToBottom();
    } catch (e) {
      _logger.e('Chatbot Error: $e');
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(
          text: 'Sorry, I am unable to connect to the legal assistant at the moment.',
          sender: MessageSender.ai,
        ));
      });
      _scrollToBottom();
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark Base
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1A237E), // Deep Blue to match Logo
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.1),
              child: const Icon(Icons.auto_awesome, color: Colors.blueAccent, size: 20),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ArguMate', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Row(
                  children: [
                    CircleAvatar(radius: 4, backgroundColor: Colors.greenAccent),
                    SizedBox(width: 4),
                    Text('Online', style: TextStyle(fontSize: 12, color: Colors.white70)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A237E), Colors.black],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Message List
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return ChatBubble(message: message);
                  },
                ),
              ),

              // Bottom Input Area
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                child: Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: TextField(
                              controller: _messageController,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                hintText: 'Ask ArguMate anything...',
                                hintStyle: TextStyle(color: Colors.white38),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              ),
                              enabled: !_isSending,
                              onSubmitted: _isSending ? null : (_) => _sendMessage(),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _isSending
                        ? const SizedBox(
                            width: 50,
                            height: 50,
                            child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: CircularProgressIndicator(color: Colors.blueAccent, strokeWidth: 2),
                            ),
                          )
                        : Container(
                            decoration: const BoxDecoration(
                              color: Colors.blueAccent,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.send_rounded, color: Colors.white),
                              onPressed: _sendMessage,
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == MessageSender.user;
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          // WhatsApp Style Glass Bubbles
          color: isUser 
              ? Colors.blueAccent.withOpacity(0.2) // User: Cyan-Blue Tint
              : Colors.white.withOpacity(0.1),      // AI: Dark Grey Tint
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isUser ? const Radius.circular(20) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(20),
          ),
          border: Border.all(
            color: isUser ? Colors.blueAccent.withOpacity(0.3) : Colors.white10,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bot Name label (Optional, only for AI)
            if (!isUser) 
              const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text('ArguMate', style: TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            Text(
              message.text,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.white,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}