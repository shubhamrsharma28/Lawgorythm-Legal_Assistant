// lib/screens/auth/login_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final Logger _logger = Logger();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  Future<void> _signIn() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      await Provider.of<AuthService>(context, listen: false).signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      _logger.i('User signed in successfully.');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Welcome to Lawgorythm!')),
      );
    } on FirebaseAuthException catch (e) {
      _logger.e('Login Failed: ${e.message}');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login Failed: ${e.message}')),
      );
    } catch (e) {
      _logger.e('Login Error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      await Provider.of<AuthService>(context, listen: false).signInWithGoogle();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google Sign-In Failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF232526), Color(0xFF414345)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/lawgorythm_logo.png',
                  height: 120,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.gavel_rounded, size: 60, color: Colors.blueAccent),
                ),
                const SizedBox(height: 10),
                
                SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      "Lawgorythm",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.audiowide(
                        textStyle: TextStyle(
                          fontSize: 50, 
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          foreground: Paint()
                            ..shader = const LinearGradient(
                              colors: [Colors.purple, Colors.cyan, Colors.blue]
                            ).createShader(const Rect.fromLTWH(0.0, 0.0, 1500.0, 70.0)),
                          shadows: [ Shadow( offset: Offset(0, 0), blurRadius: 10, color: Colors.black), ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                const Text(
                  "Your AI Legal Companion",
                  style: TextStyle(color: Colors.white70, fontSize: 16, letterSpacing: 0.5),
                ),
                
                const SizedBox(height: 30),

                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Column(
                      children: [
                        _buildModernTextField(
                          controller: _emailController,
                          hint: "Email",
                          icon: Icons.email_outlined,
                        ),
                        const SizedBox(height: 15),
                        _buildModernTextField(
                          controller: _passwordController,
                          hint: "Password",
                          icon: Icons.lock_outline,
                          isPassword: true,
                        ),
                        const SizedBox(height: 40),

                        if (_isLoading)
                          const CircularProgressIndicator(color: Colors.blueAccent)
                        else
                          Column(
                            children: [
                              ElevatedButton(
                                onPressed: _signIn,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  minimumSize: const Size(double.infinity, 55),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  elevation: 5,
                                ),
                                child: const Text("Sign In", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(height: 20),
                              const Text("OR", style: TextStyle(color: Colors.white38, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 20),
                              OutlinedButton.icon(
                                onPressed: _signInWithGoogle,
                                icon: Image.asset('assets/google_logo.png', height: 24, errorBuilder: (c, e, s) => const Icon(Icons.login, color: Colors.white)),
                                label: const Text("Continue with Google", style: TextStyle(color: Colors.white, fontSize: 16)),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 55),
                                  side: const BorderSide(color: Colors.white24),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                ),
                              ),
                            ],
                          ),

                        const SizedBox(height: 30),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const RegisterScreen()));
                          },
                          child: RichText(
                            text: const TextSpan(
                              text: "New on Lawgorythm? ",
                              style: TextStyle(color: Colors.white70),
                              children: [
                                TextSpan(
                                  text: "Register here.",
                                  style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? !_isPasswordVisible : false,
        style: const TextStyle(color: Colors.white),
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38),
          prefixIcon: Icon(icon, color: Colors.blueAccent, size: 22),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white38,
                  ),
                  onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        ),
      ),
    );
  }
}