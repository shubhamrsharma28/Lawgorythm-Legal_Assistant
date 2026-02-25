// lib/screens/fir_detail_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/fir_detail_model.dart';
import '../services/auth_service.dart';

class FirDetailScreen extends StatelessWidget {
  final String firId;

  const FirDetailScreen({super.key, required this.firId});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context, listen: false).getCurrentUser();

    if (user == null) {
      return const Scaffold(body: Center(child: Text("User not logged in.")));
    }

    // Use a FutureBuilder to fetch the document from Firestore
    final firDocFuture = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('firs')
        .doc(firId)
        .get();

    return Scaffold(
      appBar: AppBar(
        title: const Text('FIR Details'),
        backgroundColor: Colors.indigo,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: firDocFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("FIR not found."));
          }

          // Convert the data into our model
          final firData = FirDetailModel.fromFirestore(snapshot.data!);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoCard(
                  context,
                  title: 'Simplified Explanation',
                  child: Text(firData.simplifiedExplanation, style: const TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 20),
                _buildInfoCard(
                  context,
                  title: 'Structured Summary',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: firData.structuredSummary.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: RichText(
                          text: TextSpan(
                            style: Theme.of(context).textTheme.bodyLarge,
                            children: <TextSpan>[
                              TextSpan(text: '${_formatKey(entry.key)}: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(text: '${entry.value}'),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),
                if (firData.ipcSections.isNotEmpty)
                  _buildInfoCard(
                    context,
                    title: 'Suggested IPC Sections',
                    child: Column(
                      children: firData.ipcSections.map((ipc) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.gavel, color: Colors.deepOrange),
                          title: Text(ipc.section, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(ipc.reason),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Helper widget to build the info cards
  Widget _buildInfoCard(BuildContext context, {required String title, required Widget child}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.indigo, fontWeight: FontWeight.bold)),
            const Divider(height: 20, thickness: 1),
            child,
          ],
        ),
      ),
    );
  }
    
  // Helper function to format the keys from the summary map
  String _formatKey(String key) {
    return key.replaceAll('_', ' ').split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}