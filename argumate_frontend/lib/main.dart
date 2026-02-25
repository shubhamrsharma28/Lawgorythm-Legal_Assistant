// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'firebase_options.dart';
import 'providers/theme_provider.dart';
import 'services/auth_service.dart';
import 'services/fir_service.dart';
import 'services/chat_service.dart';
import 'services/history_service.dart';
import 'services/validator_service.dart';
import 'services/argument_builder_service.dart';
import 'services/case_retriever_service.dart';
import 'services/case_timeline_service.dart';
import 'services/prediction_service.dart'; 
import 'screens/auth/login_screen.dart';
import 'screens/fir_explainer_screen.dart';
import 'screens/chatbot_screen.dart';
import 'screens/history_screen.dart';
import 'screens/fir_validator_screen.dart';
import 'screens/argument_builder_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/case_retriever_screen.dart';
import 'screens/case_timeline_screen.dart';
import 'screens/prediction_screen.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: kIsWeb 
          ? DefaultFirebaseOptions.web 
          : DefaultFirebaseOptions.currentPlatform,
    );
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        Provider(create: (context) => FirService()),
        Provider(create: (context) => ChatService()),
        Provider(create: (context) => HistoryService()),
        Provider(create: (context) => ValidatorService()),
        Provider(create: (context) => ArgumentBuilderService()),
        Provider(create: (context) => CaseRetrieverService()),
        Provider(create: (context) => CaseTimelineService()),
        Provider(create: (context) => PredictionService()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Lawgorythm',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(brightness: Brightness.dark, primaryColor: const Color(0xFF1A237E)),
            // FIX: Login ke baad seedha DashboardScreen par bhejo
            home: const AuthWrapper(),
            routes: {
              '/dashboard': (context) => const DashboardScreen(),
              '/history': (context) => const HistoryScreen(),
              '/profile': (context) => const ProfileScreen(),
              '/fir_explainer': (context) => const FirExplainerScreen(),
              '/chatbot': (context) => const ChatbotScreen(),
              '/fir_validator': (context) => const FirValidatorScreen(),
              '/argument_builder': (context) => const ArgumentBuilderScreen(),
              '/case_retriever': (context) => const CaseRetrieverScreen(),
              '/case_timeline': (context) => const CaseTimelineScreen(),
              '/prediction': (context) => const PredictionScreen(), 
            },
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          // FIX: Yahan DashboardScreen load karo
          return const DashboardScreen();
        }
        return const LoginScreen();
      },
    );
  }
}