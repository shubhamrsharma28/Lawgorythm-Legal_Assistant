// lib/screens/argument_detail_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/argument_builder_model.dart';
import '../models/argument_detail_model.dart';
import '../services/auth_service.dart';

class ArgumentDetailScreen extends StatelessWidget {
  final String argumentId;

  const ArgumentDetailScreen({super.key, required this.argumentId});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context, listen: false).getCurrentUser();

    if (user == null) {
      return const Scaffold(body: Center(child: Text("User not logged in.")));
    }

    final docFuture = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('arguments_built')
        .doc(argumentId)
        .get();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Built Arguments'),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: docFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Argument details not found."));
          }

          final argumentData = ArgumentDetailModel.fromFirestore(snapshot.data!);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildArgumentSection(
                  context,
                  title: 'Prosecution Arguments',
                  arguments: argumentData.prosecutionArguments,
                  icon: Icons.gavel,
                  color: Colors.red.shade700,
                ),
                const SizedBox(height: 20),
                _buildArgumentSection(
                  context,
                  title: 'Defense Arguments',
                  arguments: argumentData.defenseArguments,
                  icon: Icons.shield,
                  color: Colors.blue.shade700,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

Widget _buildArgumentSection(
  BuildContext context, {
  required String title,
  required List<ArgumentPoint> arguments,
  required IconData icon,
  required Color color,
}) {
  return Card(
    elevation: 4,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(height: 20),
          ...arguments.map((arg) => Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Point: ${arg.point}', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Reasoning: ${arg.reasoning}'),
              ],
            ),
          )),
        ],
      ),
    ),
  );
}