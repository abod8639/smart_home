import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_service.g.dart';

@Riverpod(keepAlive: true)
class AuthService extends _$AuthService {
  late final FirebaseAuth _auth;

  @override
  void build() {
    final isTest = !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');
    if (!isTest) {
      _auth = FirebaseAuth.instance;
      if (!kIsWeb) {
        GoogleSignIn.instance.initialize(
          serverClientId: '263208865722-jhtj3i34m25u1i0svt1kdktbvukbhtjd.apps.googleusercontent.com',
        );
      }
    }
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Google Sign-In logic working across Web and Mobile
  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // Web uses popup to avoid DWDS hangs and manual client ID config
        GoogleAuthProvider authProvider = GoogleAuthProvider();
        return await _auth.signInWithPopup(authProvider);
      } else {
        // Mobile uses standard flow
        final GoogleSignInAccount googleUser = await GoogleSignIn.instance.authenticate();
        if (googleUser == null) return null;

        final GoogleSignInAuthentication googleAuth = googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );

        return await _auth.signInWithCredential(credential);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error during Google Sign-In: $e");
      }
      return null;
    }
  }

  /// Sign out from Firebase and Google Sign-In
  Future<void> signOut() async {
    try {
      if (!kIsWeb) {
        await GoogleSignIn.instance.signOut();
      }
      await _auth.signOut();
    } catch (e) {
      if (kDebugMode) {
        print("Error signing out: $e");
      }
    }
  }
}

@Riverpod(keepAlive: true)
Stream<User?> authState(Ref ref) {
  return ref.watch(authServiceProvider.notifier).authStateChanges;
}
