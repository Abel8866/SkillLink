import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'user_profile_service.dart';

class ProfileCreationException implements Exception {
  const ProfileCreationException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthService extends ChangeNotifier {
  AuthService._internal();

  static final AuthService instance = AuthService._internal();

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<User?>? _idTokenSubscription;
  User? _currentUser;
  bool _initialized = false;

  User? get currentUser => _currentUser;
  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) return;
    _currentUser = FirebaseAuth.instance.currentUser;
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      _currentUser = user;
      notifyListeners();
    });
    _idTokenSubscription = FirebaseAuth.instance.idTokenChanges().listen((
      user,
    ) {
      _currentUser = user;
      notifyListeners();
    });
    _initialized = true;
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-created',
        message: 'The account could not be created.',
      );
    }

    await user.updateDisplayName(name.trim());
    try {
      await UserProfileService.instance.createProfile(
        uid: user.uid,
        name: name.trim(),
        email: email.trim(),
      );
    } catch (error) {
      throw ProfileCreationException(
        'Your account was created, but the profile could not be saved. '
        'Use “Retry profile setup” before trying to register again.',
      );
    }
  }

  Future<void> retryProfileCreation({required String name}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw const ProfileCreationException(
        'Please sign in again before retrying profile setup.',
      );
    }
    await UserProfileService.instance.createProfile(
      uid: user.uid,
      name: name.trim().isEmpty ? (user.displayName ?? '') : name.trim(),
      email: user.email ?? '',
    );
  }

  Future<void> signIn({required String email, required String password}) async {
    final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await credential.user?.getIdToken(true);
  }

  Future<bool> refreshAdminClaim() async {
    final user = _currentUser ?? FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('[AuthService] Admin claim check skipped: no signed-in user.');
      return false;
    }
    try {
      await user.reload();
      final refreshedUser = FirebaseAuth.instance.currentUser;
      if (refreshedUser == null) {
        debugPrint(
          '[AuthService] Admin claim check failed: user signed out during refresh.',
        );
        return false;
      }
      final token = await refreshedUser.getIdTokenResult(true);
      final isAdmin = token.claims?['admin'] == true;
      debugPrint(
        '[AuthService] Admin claim check for UID ${refreshedUser.uid}: '
        'admin=$isAdmin',
      );
      return isAdmin;
    } on FirebaseException catch (error, stackTrace) {
      debugPrint(
        '[AuthService] Admin claim refresh failed '
        '(code=${error.code}): ${error.message ?? error}',
      );
      debugPrintStack(stackTrace: stackTrace);
      return false;
    } catch (error, stackTrace) {
      debugPrint('[AuthService] Admin claim refresh failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    }
  }

  Future<void> sendPasswordReset(String email) {
    return FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> signOut() => FirebaseAuth.instance.signOut();

  @override
  void dispose() {
    _authSubscription?.cancel();
    _idTokenSubscription?.cancel();
    super.dispose();
  }
}
