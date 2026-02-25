// lib/services/history_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';

import '../models/fir_list_model.dart';
import '../models/chat_list_model.dart';
//import '../models/retrieved_case_list_model.dart';
import '../models/recent_activity_model.dart';

class HistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Logger _logger = Logger();

  // --- BAKI SABHI FUNCTIONS WAISE HI RAHENGE ---
  // (getFirHistory, getChatHistory, getFirCount, etc...)
  Stream<List<FirListItem>> getFirHistory() {
    final user = _auth.currentUser;
    if (user == null) {
      _logger.w('Attempted to get FIR history but no user is logged in.');
      return Stream.value([]);
    }
    
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('firs')
        .orderBy('uploaded_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => FirListItem.fromFirestore(doc)).toList();
    });
  }

  Stream<List<ChatListItem>> getChatHistory() {
    final user = _auth.currentUser;
    if (user == null) {
      _logger.w('Attempted to get chat history but no user is logged in.');
      return Stream.value([]);
    }
    
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('chat_history')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ChatListItem.fromFirestore(doc)).toList();
    });
  }
    
  Stream<int> getFirCount() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(0);
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('firs')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<int> getChatHistoryCount() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(0);
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('chat_history')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<int> getArgumentCount() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(0);
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('arguments_built') 
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // --- YAHAN getRecentActivity FUNCTION KO UPDATE KIYA GAYA HAI ---
  Stream<List<RecentActivityItem>> getRecentActivity() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    final firsStream = _firestore
        .collection('users').doc(user.uid).collection('firs')
        .orderBy('uploaded_at', descending: true).limit(3).snapshots();

    final chatsStream = _firestore
        .collection('users').doc(user.uid).collection('chat_history')
        .orderBy('timestamp', descending: true).limit(3).snapshots();
    
    final argumentsStream = _firestore
        .collection('users').doc(user.uid).collection('arguments_built')
        .orderBy('timestamp', descending: true).limit(3).snapshots();

    return Rx.combineLatest3(
      firsStream,
      chatsStream,
      argumentsStream,
      (QuerySnapshot firs, QuerySnapshot chats, QuerySnapshot args) {
        
        final List<RecentActivityItem> items = [];

        for (var doc in firs.docs) {
          final data = doc.data() as Map<String, dynamic>;
          items.add(RecentActivityItem(
            id: doc.id,
            title: data['filename'] ?? 'FIR Explained',
            timestamp: data['uploaded_at'],
            type: ActivityType.fir,
          ));
        }

        for (var doc in chats.docs) {
          final data = doc.data() as Map<String, dynamic>;
          items.add(RecentActivityItem(
            id: doc.id,
            title: data['user_message'] ?? 'Chat Query',
            timestamp: data['timestamp'],
            type: ActivityType.chat,
          ));
        }

        for (var doc in args.docs) {
          final data = doc.data() as Map<String, dynamic>;
          // Safely get the title by checking for both new and old field names
          final title = data.containsKey('case_summary')
              ? data['case_summary']
              : (data.containsKey('case_summary_start')
                  ? data['case_summary_start']
                  : 'Argument Built'); // Fallback title

          items.add(RecentActivityItem(
            id: doc.id,
            title: title,
            timestamp: data['timestamp'],
            type: ActivityType.argument,
          ));
        }

        items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        
        return items.take(4).toList();
      },
    );
  }
}