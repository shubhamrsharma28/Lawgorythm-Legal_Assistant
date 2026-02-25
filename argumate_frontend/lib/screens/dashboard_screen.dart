// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart'; 
import '../services/auth_service.dart';
import '../services/history_service.dart';
import '../models/recent_activity_model.dart';

class Feature {
  final String title; final IconData icon; final Color color; final String routeName;
  Feature({required this.title, required this.icon, required this.color, required this.routeName});
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ScrollController _scrollController = ScrollController();
  
  double _fabOpacity = 0.0;

  @override
  void initState() {
    super.initState();
  
    _scrollController.addListener(() {
      if (_scrollController.offset > 200 && _fabOpacity == 0) {
        setState(() => _fabOpacity = 1.0);
      } else if (_scrollController.offset <= 200 && _fabOpacity == 1) {
        setState(() => _fabOpacity = 0.0);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userName = authService.getCurrentUser()?.displayName ?? 'Shubham Sharma';

    final List<Feature> features = [
      Feature(title: 'Prediction', icon: Icons.online_prediction_rounded, color: Colors.redAccent, routeName: '/prediction'),
      Feature(title: 'Case Timeline', icon: Icons.timeline_rounded, color: Colors.cyanAccent, routeName: '/case_timeline'),
      Feature(title: 'Case Retriever', icon: Icons.find_in_page_rounded, color: Colors.orangeAccent, routeName: '/case_retriever'),
      Feature(title: 'Arguments', icon: Icons.gavel_rounded, color: Colors.tealAccent, routeName: '/argument_builder'),
      Feature(title: 'Validator', icon: Icons.verified_user_rounded, color: Colors.purpleAccent, routeName: '/fir_validator'),
      Feature(title: 'FIR Explainer', icon: Icons.description_rounded, color: Colors.greenAccent, routeName: '/fir_explainer'),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: null, 
      
      floatingActionButton: AnimatedOpacity(
        duration: const Duration(milliseconds: 800),
        opacity: _fabOpacity,
        child: FloatingActionButton(
          onPressed: () => Navigator.of(context).pushNamed('/chatbot'),
          backgroundColor: const Color(0xFF1A237E),
          child: const Icon(Icons.auto_awesome, color: Colors.blueAccent),
        ),
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        elevation: 4,
        toolbarHeight: 80,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset(
              'assets/lawgorythm_logo.png',   
              height: 55,                      
            ),
            const SizedBox(width: 10),        
            Text(
              "Lawgorythm",
             
              style: GoogleFonts.audiowide(
                fontWeight: FontWeight.w900, 
                fontSize: 30,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          _buildNavTextButton("Dashboard", Icons.dashboard_rounded, () => _scrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut)),
          _buildNavTextButton("History", Icons.history_rounded, () => Navigator.of(context).pushNamed('/history')),
          Padding(
            padding: const EdgeInsets.only(right: 25, left: 10),
            child: InkWell(
              onTap: () => Navigator.of(context).pushNamed('/profile'),
              borderRadius: BorderRadius.circular(25),
              child: const CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white24,
                backgroundImage: AssetImage('assets/user_logo.png'), 
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF1A237E), Colors.black], begin: Alignment.topCenter, end: Alignment.bottomCenter),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Welcome Back,', style: TextStyle(color: Colors.white70, fontSize: 18)),
                      Text(userName, style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 30),
                      _buildQuickChatAction(context),
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('AI Legal Services', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 25),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 18, mainAxisSpacing: 18, childAspectRatio: 1.4),
                        itemCount: features.length,
                        itemBuilder: (context, index) => _buildFeatureCard(context, features[index]),
                      ),
                      const SizedBox(height: 60),
                      const Text('Recent Activity', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),
                      _buildRecentActivityList(context),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 100),
            _buildWebFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildNavTextButton(String title, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: TextButton.icon(onPressed: onTap, icon: Icon(icon, color: Colors.white70, size: 18), label: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16))),
    );
  }

  Widget _buildQuickChatAction(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed('/chatbot'),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white10)),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.auto_awesome, color: Colors.blueAccent), SizedBox(width: 15), Text("Launch ArguMate AI Assistant", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))]),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, Feature feature) {
    return Card(
      color: Colors.white.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: const BorderSide(color: Colors.white10)),
      child: InkWell(onTap: () => Navigator.of(context).pushNamed(feature.routeName), borderRadius: BorderRadius.circular(18), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(feature.icon, size: 32, color: feature.color), const SizedBox(height: 10), Text(feature.title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold))])),
    );
  }

  Widget _buildWebFooter() {
    return Container(
      width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 50),
      decoration: const BoxDecoration(color: Color(0xFF0A0E21), border: Border(top: BorderSide(color: Colors.white12))),
      child: Column(children: [const Text("© 2026 Lawgorythm. All Rights reserved.", style: TextStyle(color: Colors.white38, fontSize: 14)), const SizedBox(height: 12), Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Text("Made with ", style: TextStyle(color: Colors.white38, fontSize: 14)), const Icon(Icons.favorite, color: Colors.redAccent, size: 18), const Text(" by Shubham", style: TextStyle(color: Colors.white38, fontSize: 14, fontWeight: FontWeight.bold))])]),
    );
  }

  Widget _buildRecentActivityList(BuildContext context) {
    final historyService = Provider.of<HistoryService>(context, listen: false);
    return StreamBuilder<List<RecentActivityItem>>(
      stream: historyService.getRecentActivity(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        final items = snapshot.data!;
        return Column(children: items.take(3).map((item) => Container(margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.04), borderRadius: BorderRadius.circular(15)), child: ListTile(leading: const Icon(Icons.history, color: Colors.white24, size: 20), title: Text(item.title, style: const TextStyle(color: Colors.white70, fontSize: 14)), trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white12, size: 12), onTap: () {}))).toList());
      },
    );
  }
}