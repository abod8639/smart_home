import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Rx<User?> currentUser = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();
    if (!kIsWeb) {
      GoogleSignIn.instance.initialize();
    }
    // Bind current user to firebase auth changes
    currentUser.bindStream(_auth.authStateChanges());
    
    // Auth router: automatically redirect routes based on login state
    ever(currentUser, _handleAuthChanged);
  }

  void _handleAuthChanged(User? user) {
    if (user == null) {
      // Direct to login page if logged out
      Get.offAllNamed('/login');
    } else {
      // Direct to dashboard if logged in
      Get.offAllNamed('/dashboard');
    }
  }

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
