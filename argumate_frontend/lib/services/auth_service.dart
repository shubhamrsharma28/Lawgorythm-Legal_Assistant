// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // FIXED: ID ko yahan zabardasti daal diya hai taaki crash na ho
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '792322971269-1o2ljd7m6egfq77sidr8e4gcutom10ro.apps.googleusercontent.com',
  ); 
  
  final Logger _logger = Logger();

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<UserCredential?> signUpWithEmailAndPassword(
      String email, String password, String displayName) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user?.updateDisplayName(displayName);
      _logger.i('User signed up: ${userCredential.user?.email}');
      notifyListeners();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      _logger.e('Firebase Auth Sign Up Error: ${e.code} - ${e.message}');
      throw Exception(e.message);
    } catch (e) {
      _logger.e('General Sign Up Error: $e');
      throw Exception('An unexpected error occurred during sign up.');
    }
  }

  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _logger.i('User signed in: ${userCredential.user?.email}');
      notifyListeners();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      _logger.e('Firebase Auth Sign In Error: ${e.code} - ${e.message}');
      throw Exception(e.message);
    } catch (e) {
      _logger.e('General Sign In Error: $e');
      throw Exception('An unexpected error occurred during sign in.');
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      _logger.i('User signed in with Google: ${userCredential.user?.email}');

      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        final userRef = _firestore.collection('users').doc(userCredential.user!.uid);
        await userRef.set({
          'email': userCredential.user!.email,
          'display_name': userCredential.user!.displayName,
          'created_at': FieldValue.serverTimestamp(),
        });
      }

      notifyListeners();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      _logger.e('Google Sign-In Error: ${e.message}');
      throw Exception(e.message);
    } catch (e) {
      _logger.e('An unexpected error occurred during Google Sign-In: $e');
      throw Exception('An unexpected error occurred.');
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user is currently signed in.');
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);
      } on FirebaseAuthException catch (e) { 
      _logger.e('Password change failed: ${e.message}');
      rethrow;
    } catch (e) {
      _logger.e('An unexpected error occurred: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      _logger.i('User signed out');
      notifyListeners();
    } catch (e) {
      _logger.e('Sign Out Error: $e');
      throw Exception('An error occurred during sign out.');
    }
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}