// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb show User;
// import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';
import '../utils/constants.dart';

/// Handles registration, login, and session state via Firebase Authentication,
/// mirroring the "User Onboarding" scope item (secure account creation, login,
/// profile editing, notification preferences).
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // final FirebaseFirestore _db = FirebaseFirestore.instance;
  // TODO: Re-enable Firestore when billing is available and Firestore is enabled.

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? ward,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final uid = credential.user!.uid;

    final appUser = AppUser(
      uid: uid,
      name: name.trim(),
      email: email.trim(),
      phone: phone,
      ward: ward,
      role: UserRole.resident,
      createdAt: DateTime.now(),
    );

    // Persisting user profile to Firestore is disabled temporarily because
    // Firestore is not available (billing). Commented out so it can be
    // restored later.
    // TODO: Restore this once Firestore is enabled.
    // await _db.collection(FirestoreCollections.users).doc(uid).set(appUser.toMap());
    await credential.user!.updateDisplayName(name.trim());

    print('AuthService: register successful for uid=$uid');
    return appUser;
  }

  Future<AppUser> login({required String email, required String password}) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    print('AuthService: login successful for uid=${credential.user?.uid}');
    return fetchUserProfile(credential.user!.uid);
  }

  Future<AppUser> fetchUserProfile(String uid) async {
    // Firestore reads are disabled until billing is available. Attempting a
    // Firestore read would fail, so return a temporary AppUser constructed
    // from the Firebase Auth user data. When Firestore is enabled this
    // method should read the full profile from Firestore.
    // TODO: Uncomment Firestore read and remove fallback when Firestore is enabled.
    /*
    final doc = await _db.collection(FirestoreCollections.users).doc(uid).get();
    if (!doc.exists) {
      throw Exception('User profile not found. Please contact support.');
    }
    return AppUser.fromMap(uid, doc.data()!);
    */

    final fb.User? fbUser = _auth.currentUser;
    final name = fbUser?.displayName ?? 'New User';
    final email = fbUser?.email ?? '';
    final fallback = AppUser(
      uid: uid,
      name: name,
      email: email,
      phone: null,
      ward: null,
      role: UserRole.resident,
      notificationPrefs: const ['local', 'emergency'],
      createdAt: DateTime.now(),
    );
    print('AuthService: returning fallback AppUser for uid=$uid');
    return fallback;
  }

  Future<void> updateNotificationPrefs(String uid, List<String> categories) async {
    // TODO: Re-enable when Firestore is available. Currently a no-op.
    // await _db.collection(FirestoreCollections.users).doc(uid).update({
    //   'notificationPrefs': categories,
    // });
    print('AuthService: updateNotificationPrefs skipped (Firestore disabled) for uid=$uid');
  }

  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Human-readable error mapping for common Firebase Auth exceptions.
  String friendlyError(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'An account already exists with this email.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'weak-password':
          return 'Password should be at least 6 characters.';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Incorrect email or password.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        default:
          return error.message ?? 'Something went wrong. Please try again.';
      }
    }
    return 'Something went wrong. Please try again.';
  }
}
