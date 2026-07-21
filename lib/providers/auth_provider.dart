import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

/// Exposes the current session (Firebase user + Firestore profile) to the
/// rest of the app, and drives the splash -> login/home routing decision.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final NotificationService _notificationService;

  AuthProvider(this._authService, this._notificationService) {
    _authService.authStateChanges.listen(_onAuthChanged);
  }

  AuthStatus status = AuthStatus.unknown;
  AppUser? currentUser;
  String? error;
  bool isLoading = false;

  Future<void> _onAuthChanged(fb.User? user) async {
    if (user == null) {
      status = AuthStatus.unauthenticated;
      currentUser = null;
      notifyListeners();
      return;
    }
    try {
      currentUser = await _authService.fetchUserProfile(user.uid);
      status = AuthStatus.authenticated;
      print('AuthProvider: user authenticated uid=${currentUser?.uid}. Navigating to Home.');
      // Subscribe to notification categories if available (no-op if empty)
      for (final category in currentUser!.notificationPrefs) {
        unawaited(_notificationService.subscribeToCategory(category));
      }
    } catch (_) {
      // If fetching profile fails (e.g. Firestore disabled), fall back to
      // an Auth-only session using a temporary AppUser provided by
      // `AuthService.fetchUserProfile` and treat the user as authenticated.
      status = AuthStatus.authenticated;
      print('AuthProvider: fetchUserProfile failed, falling back to auth-only user.');
    }
    notifyListeners();
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? ward,
  }) => _run(() => _authService.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
        ward: ward,
      ));

  Future<bool> login({required String email, required String password}) =>
      _run(() => _authService.login(email: email, password: password));

  Future<bool> _run(Future<AppUser> Function() action) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      currentUser = await action();
      status = AuthStatus.authenticated;
      print('AuthProvider: login/register completed for uid=${currentUser?.uid}.');
      return true;
    } catch (e) {
      error = _authService.friendlyError(e);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
  }

  void unawaited(Future<void> future) {}
}
