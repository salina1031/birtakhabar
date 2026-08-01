import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb show User;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';
import '../utils/constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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

    await _db.collection(FirestoreCollections.users).doc(uid).set(appUser.toMap());
    await credential.user!.updateDisplayName(name.trim());
    return appUser;
  }

  Future<AppUser> login({required String email, required String password}) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return fetchUserProfile(credential.user!.uid);
  }

  Future<AppUser> fetchUserProfile(String uid) async {
    final doc = await _db.collection(FirestoreCollections.users).doc(uid).get();
    if (!doc.exists) {
      // Covers accounts created before this fix - backfill a profile doc.
      final fbUser = _auth.currentUser;
      final fallback = AppUser(
        uid: uid,
        name: fbUser?.displayName ?? 'New User',
        email: fbUser?.email ?? '',
        role: UserRole.resident,
        createdAt: DateTime.now(),
      );
      await _db.collection(FirestoreCollections.users).doc(uid).set(fallback.toMap());
      return fallback;
    }
    return AppUser.fromMap(uid, doc.data()!);
  }

  Future<void> updateNotificationPrefs(String uid, List<String> categories) async {
    await _db.collection(FirestoreCollections.users).doc(uid).update({
      'notificationPrefs': categories,
    });
  }

  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

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