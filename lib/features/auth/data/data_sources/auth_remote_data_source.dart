import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/user_model.dart';

part 'auth_remote_data_source.g.dart';

/// Contract for the remote authentication data source.
abstract class AuthRemoteDataSource {
  /// Stream emitting changes to the authenticated user.
  Stream<UserModel?> get authStateChanges;

  /// Initiates the Google Sign-In flow across Web and native mobile platforms.
  Future<UserModel?> signInWithGoogle();

  /// Signs out of Firebase and Google Sign-In.
  Future<void> signOut();

  /// Returns the currently authenticated [UserModel], or null.
  UserModel? get currentUser;
}

/// Firebase & GoogleSignIn implementation of [AuthRemoteDataSource].
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final Completer<void> _initCompleter = Completer<void>();

  AuthRemoteDataSourceImpl({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance {
    _initializeGoogleSignIn();
  }

  bool get _isTest =>
      !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');

  Future<void> _initializeGoogleSignIn() async {
    if (kIsWeb || _isTest) {
      if (!_initCompleter.isCompleted) {
        _initCompleter.complete();
      }
      return;
    }

    try {
      await GoogleSignIn.instance.initialize(
        serverClientId:
            '263208865722-jhtj3i34m25u1i0svt1kdktbvukbhtjd.apps.googleusercontent.com',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing Google Sign-In: $e');
      }
    } finally {
      if (!_initCompleter.isCompleted) {
        _initCompleter.complete();
      }
    }
  }

  @override
  Stream<UserModel?> get authStateChanges =>
      _firebaseAuth.authStateChanges().map((user) =>
          user != null ? UserModel.fromFirebaseUser(user) : null);

  @override
  UserModel? get currentUser {
    final user = _firebaseAuth.currentUser;
    return user != null ? UserModel.fromFirebaseUser(user) : null;
  }

  @override
  Future<UserModel?> signInWithGoogle() async {
    await _initCompleter.future;
    try {
      if (kIsWeb) {
        final GoogleAuthProvider authProvider = GoogleAuthProvider();
        final credential = await _firebaseAuth.signInWithPopup(authProvider);
        final user = credential.user;
        return user != null ? UserModel.fromFirebaseUser(user) : null;
      } else {
        final GoogleSignInAccount googleUser =
            await GoogleSignIn.instance.authenticate();
        final GoogleSignInAuthentication googleAuth =
            googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );

        final userCredential =
            await _firebaseAuth.signInWithCredential(credential);
        final user = userCredential.user;
        return user != null ? UserModel.fromFirebaseUser(user) : null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during Google Sign-In in AuthRemoteDataSource: $e');
      }
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      if (!kIsWeb && !_isTest) {
        await GoogleSignIn.instance.signOut();
      }
      await _firebaseAuth.signOut();
    } catch (e) {
      if (kDebugMode) {
        print('Error signing out in AuthRemoteDataSource: $e');
      }
    }
  }
}

/// Provider for accessing [AuthRemoteDataSource].
@riverpod
AuthRemoteDataSource authRemoteDataSource(Ref ref) {
  return AuthRemoteDataSourceImpl();
}
