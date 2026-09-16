import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream for auth state changes
  Stream<User?> get userStream => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow (v7.x uses authenticate)
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      // Obtain the auth details from the account
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // Create a new credential (v7.x primarily provides idToken for identity)
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      // Update user data in Firestore
      if (userCredential.user != null) {
        await _updateUserInFirestore(userCredential.user!);
      }

      return userCredential;
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      return null;
    }
  }

  // Update user data in Firestore
  Future<void> _updateUserInFirestore(User user) async {
    DocumentReference userRef = _db.collection('users').doc(user.uid);
    const String currentAppId = '352mShnp5poSiabgFqDq';

    try {
      final doc = await userRef.get();
      
      if (!doc.exists) {
        // New user: Create document
        await userRef.set({
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName,
          'photoURL': user.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
          'role': 'user',
          'firstAppId': currentAppId, // Store source app ID
        });
      } else {
        // Existing user: Update last login and check for missing fields
        final data = doc.data() as Map<String, dynamic>;
        Map<String, dynamic> updates = {
          'displayName': user.displayName,
          'photoURL': user.photoURL,
          'lastLogin': FieldValue.serverTimestamp(),
        };

        // Add firstAppId if it doesn't exist yet (for older users)
        if (!data.containsKey('firstAppId')) {
          updates['firstAppId'] = currentAppId;
        }

        await userRef.update(updates);
      }
    } catch (e) {
      debugPrint('Error updating user data in Firestore: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
