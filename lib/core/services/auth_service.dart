import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// [AuthService] is a modular authentication handler for Firebase and Google Sign-In.
/// 
/// Dependencies:
/// - firebase_auth
/// - google_sign_in (v7.x optimized)
/// - cloud_firestore
class AuthService {
  // Service instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Unique App Identifier for user tracking across different client apps.
  /// Update this string when reusing this service in a new project.
  static const String currentAppId = '352mShnp5poSiabgFqDq';

  /// Stream to listen for real-time authentication state changes.
  Stream<User?> get userStream => _auth.authStateChanges();

  /// Returns the currently signed-in Firebase [User], or null.
  User? get currentUser => _auth.currentUser;

  /// Initiates the Google Sign-In flow and synchronizes user data with Firestore.
  /// 
  /// Returns [UserCredential] on success, or null if canceled/failed.
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // 1. Trigger the Google Authentication flow
      // Using authenticate() for compatibility with the latest Google Identity Services (v7+)
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 2. Create a credential for Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        // Note: accessToken is omitted for compatibility with GIS v7.x auth flow
      );

      // 3. Sign in to Firebase and return the result
      final UserCredential result = await _auth.signInWithCredential(credential);
      
      if (result.user != null) {
        await _syncUserMetadata(result.user!);
      }

      return result;
    } catch (e) {
      _logError('signInWithGoogle', e);
      return null;
    }
  }

  /// Direct Email & Password Sign-In.
  /// Required for Google Play Store review access (Testing Accounts).
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        await _syncUserMetadata(result.user!);
      }

      return result;
    } catch (e) {
      _logError('signInWithEmail', e);
      return null;
    }
  }

  /// Synchronizes authenticated user metadata to the Firestore 'users' collection.
  Future<void> _syncUserMetadata(User user) async {
    try {
      final DocumentReference userRef = _db.collection('users').doc(user.uid);
      final DocumentSnapshot doc = await userRef.get();
      final now = FieldValue.serverTimestamp();

      if (!doc.exists) {
        // Handle new user registration
        await userRef.set({
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName,
          'photoURL': user.photoURL,
          'createdAt': now,
          'lastLogin': now,
          'role': 'user',
          'firstAppId': currentAppId,
        });
      } else {
        // Handle returning user: update profile and tracking data
        final data = doc.data() as Map<String, dynamic>;
        final Map<String, dynamic> updates = {
          'displayName': user.displayName,
          'photoURL': user.photoURL,
          'lastLogin': now,
        };

        // Retroactively assign firstAppId if field is missing (for legacy users)
        if (!data.containsKey('firstAppId')) {
          updates['firstAppId'] = currentAppId;
        }

        await userRef.update(updates);
      }
    } catch (e) {
      _logError('_syncUserMetadata', e);
    }
  }

  /// Updates the password for the current authenticated user.
  /// Use this to allow Google users to set a password for future Email/Password login.
  Future<bool> updatePassword(String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
        return true;
      }
      return false;
    } catch (e) {
      _logError('updatePassword', e);
      return false;
    }
  }

  /// Signs out from both Google and Firebase.
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      _logError('signOut', e);
    }
  }

  /// Internal error logging helper.
  void _logError(String method, dynamic error) {
    debugPrint('AuthService.$method Error: $error');
  }
}
