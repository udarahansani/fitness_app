import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => currentUser != null;
  
  // Email & Password Authentication
  Future<UserCredential?> signUpWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password,
      );
      
      // Create user document in Firestore
      await _createUserDocument(result.user!);
      
      notifyListeners();
      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }
  
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update last login time
      await _updateLastLogin(result.user!.uid);
      
      notifyListeners();
      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }
  
  // Google Sign In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      UserCredential result = await _auth.signInWithCredential(credential);
      await _createUserDocument(result.user!);
      
      notifyListeners();
      return result;
    } catch (e) {
      throw 'Google Sign In Error: $e';
    }
  }
  
  // Reset Password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }
  
  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    notifyListeners();
  }
  
  // Helper Methods
  Future<void> _createUserDocument(User user) async {
    final userDoc = _firestore.collection('users').doc(user.uid);
    final docSnapshot = await userDoc.get();
    
    if (!docSnapshot.exists) {
      final userData = UserModel(
        uid: user.uid,
        email: user.email!,
        displayName: user.displayName,
        photoURL: user.photoURL,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
      
      await userDoc.set(userData.toFirestore());
    }
  }
  
  Future<void> _updateLastLogin(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'lastLoginAt': DateTime.now(),
    });
  }
  
  String _handleAuthError(FirebaseAuthException e) {
    print('Firebase Auth Error: ${e.code} - ${e.message}');
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'configuration-not-found':
        return 'Firebase configuration error. Please check Firebase Console settings.';
      case 'app-check-token-invalid':
        return 'App verification failed. Please try again.';
      default:
        return 'Authentication error: ${e.message ?? 'Unknown error'}';
    }
  }
  
  // Get current user data
  Future<UserModel?> getCurrentUserData() async {
    if (currentUser == null) return null;
    
    try {
      final doc = await _firestore.collection('users').doc(currentUser!.uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }
  
  // Update user profile
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    if (currentUser == null) return;
    
    try {
      await _firestore.collection('users').doc(currentUser!.uid).update(data);
      notifyListeners();
    } catch (e) {
      throw 'Failed to update profile: $e';
    }
  }
}