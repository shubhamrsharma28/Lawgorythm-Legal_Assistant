// lib/models/recent_activity_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum ActivityType { fir, chat, argument }

class RecentActivityItem {
  final String id;
  final String title;
  final Timestamp timestamp;
  final ActivityType type;

  RecentActivityItem({
    required this.id,
    required this.title,
    required this.timestamp,
    required this.type,
  });
}