import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_assignment_auth_maps/pages/export_pages.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService extends ChangeNotifier {
  final googleSignIn = GoogleSignIn();
  late bool _isSigningIn;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  GoogleSignInService() {
    _isSigningIn = false;
  }

  bool get isSigningIn => _isSigningIn;

  set isSigningIn(bool isSigningIn) {
    _isSigningIn = isSigningIn;
    notifyListeners();
  }

  Future login(context) async {
    isSigningIn = true;
    final user = await googleSignIn.signIn();
    if (user == null) {
      isSigningIn = false;
      return;
    } else {
      final googleAuth = await user.authentication;
      final credentials = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credentials);
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => GoogleMapSample()));
      isSigningIn = false;
    }
  }

  Future logout() async {
    await googleSignIn.disconnect();
    FirebaseAuth.instance.signOut();
  }
}
