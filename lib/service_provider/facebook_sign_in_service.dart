import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_assignment_auth_maps/pages/export_pages.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class FacebookSignInService extends ChangeNotifier{
  var loading = false;
  LoginResult? facebookLoginResult;

  void loginWithFacebook(context) async {
    loading = true;
    try {
      final facebookLoginResult = await FacebookAuth.instance.login();
      // final userData = await FacebookAuth.instance.getUserData();
      final facebookAuthCredential = FacebookAuthProvider.credential(
          facebookLoginResult.accessToken!.token);
      await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => GoogleMapSample()));
    } on FirebaseAuthException catch (e) {
      var content = '';
      switch (e.code) {
        case 'account-exists-with-different-credential':
          content = 'This account exits with a different sign in provider.';
          break;
        case 'invalid-credential':
          content = 'Unknown error has occurred.';
          break;
        case 'operation-not-allowed':
          content = 'Operation is not allowed.';
          break;
        case 'user-disabled':
          content = 'The user you tried to log into is disabled.';
          break;
        case 'user-not-found':
          content = 'The user you tried to log into was not found.';
          break;
      }
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Login with facebook failed'),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            )
          ],
        ),
      );
    } finally {
      loading = false;
    }
  }
  Future logout(context) async{
    FacebookAuth.instance.logOut();
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => SigninPage()));
  }
}
