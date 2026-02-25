// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/history_service.dart';
import '../providers/theme_provider.dart';
import 'change_password_screen.dart';

// --- NAYI SCREENS MEIN CONTENT ADD KIYA GAYA HAI ---

// 1. HELP & FAQ SCREEN
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Help & FAQ')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            'Frequently Asked Questions',
            // Theme-based color ka istemal
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const _FaqItem(
            question: 'Is ArguMate a replacement for a lawyer?',
            answer: 'No. ArguMate is an AI-powered tool designed for informational and educational purposes only. It does not provide legal advice, and its analysis should not be considered a substitute for consultation with a qualified legal professional.',
          ),
          const _FaqItem(
            question: 'How accurate are the AI predictions and analyses?',
            answer: 'Our AI models are trained on a vast dataset of legal documents, but they are not infallible. The generated arguments, predictions, and explanations are based on patterns in the data and should be used as a starting point for your research, not as a definitive legal conclusion.',
          ),
          const _FaqItem(
            question: 'Is my data secure?',
            answer: 'Yes, we take data security seriously. All your data is encrypted and stored securely. We use Firebase Authentication to protect your account. For more details, please see our Privacy Policy.',
          ),
        ],
      ));
}

// 2. PRIVACY POLICY SCREEN
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          '''Last Updated: 30 August 2025

Welcome to ArguMate. This Privacy Policy explains how we collect, use, and share information about you when you use our app.

1. Information We Collect
- Account Information: When you create an account, we collect your name, email address, and password.
- User Content: We collect the case summaries, FIR texts, and other information you provide when using our services. This data is linked to your user ID to provide you with a personalized history.

2. How We Use Your Information
- To provide and improve our services.
- To personalize your experience.
- To communicate with you about your account or our services.

3. Data Security
We implement strong security measures to protect your information. Your password is encrypted, and your data is stored in a secure Firestore database with strict access rules.

4. Data Sharing
We do not sell your personal data. We may share anonymized data with third-party services like Google's Gemini AI to power our features.

For any questions, please contact us at support@argumate.com.''',
          // Theme-based color ka istemal
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
        ),
      ));
}

// 3. ABOUT SCREEN
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('About ArguMate')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.gavel_rounded, size: 80, color: Colors.blueAccent),
            const SizedBox(height: 16),
            Text('ArguMate', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            // Theme-based color ka istemal
            Text('Version 1.0.0', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),
            Text(
              'ArguMate is a revolutionary AI legal assistant designed to empower law students, professionals, and anyone interested in the Indian legal system. Our powerful tools help you analyze documents, build arguments, and understand complex legal procedures with ease.',
              textAlign: TextAlign.center,
              // Theme-based color ka istemal
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
            ),
          ],
        ),
      ));
}

// Helper widget for FAQ items
class _FaqItem extends StatelessWidget {
  final String question;
  final String answer;
  const _FaqItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      // Card ka color theme se aayega, isliye dark mode mein apne aap aacha dikhega
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme-based color ka istemal
            Text(question, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            // Theme-based color ka istemal
            Text(answer, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final historyService = Provider.of<HistoryService>(context, listen: false);
    final user = authService.getCurrentUser();
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: ListView(
        children: [
          _buildUserProfileHeader(user),
          _buildSectionHeader('Statistics'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                StreamBuilder<int>(
                  stream: historyService.getFirCount(),
                  builder: (context, snapshot) {
                    final count = snapshot.data ?? 0;
                    return _buildStatTile(
                      Icons.description,
                      'FIRs Explained',
                      count.toString(),
                    );
                  },
                ),
                StreamBuilder<int>(
                  stream: historyService.getChatHistoryCount(),
                  builder: (context, snapshot) {
                    final count = snapshot.data ?? 0;
                    return _buildStatTile(
                      Icons.question_answer,
                      'Chat Queries',
                      count.toString(),
                    );
                  },
                ),
                StreamBuilder<int>(
                  stream: historyService.getArgumentCount(),
                  builder: (context, snapshot) {
                    final count = snapshot.data ?? 0;
                    return _buildStatTile(
                      Icons.construction,
                      'Arguments Built',
                      count.toString(),
                    );
                  },
                ), 
              ],
            ),
          ),
          _buildSectionHeader('Settings'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  secondary: const Icon(Icons.dark_mode_outlined),
                  value: themeProvider.themeMode == ThemeMode.dark,
                  onChanged: (bool value) {
                    themeProvider.toggleTheme(value);
                  },
                ),
                _buildSettingsTile(Icons.lock_reset, 'Change Password', () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ChangePasswordScreen(),
                    ),
                  );
                }),
              ],
            ),
          ),
          _buildSectionHeader('Support & Legal'),
          _buildSupportCard(context),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () async {
                await authService.signOut();
                // To prevent showing a black screen after logout before redirect
                if (context.mounted) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              },
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfileHeader(User? user) {
    // Logic ko dashboard jaisa hi banaya gaya hai taaki consistency rahe
    final String displayName =
        user?.displayName?.isNotEmpty == true
            ? user!.displayName!
            : 'User'; // Fallback mein email ki jagah 'User' dikhayega

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1)),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.blueAccent,
            child: Icon(Icons.person, size: 40, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? 'No email found',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSupportCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          _buildSettingsTile(Icons.help_outline, 'Help & FAQ', () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const HelpScreen()));
          }),
          _buildSettingsTile(Icons.policy, 'Privacy Policy', () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
            );
          }),
          _buildSettingsTile(Icons.info_outline, 'About ArguMate', () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const AboutScreen()));
          }),
        ],
      ),
    );
  }

  ListTile _buildStatTile(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(title),
      trailing: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  ListTile _buildSettingsTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade700),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
