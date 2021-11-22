import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_assignment_auth_maps/main.dart';
import 'package:flutter_assignment_auth_maps/pages/export_pages.dart';

class GmailSignInService extends ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  late String _errorMessage = "";

  String get errorMessage => _errorMessage;

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Future register(String email, String password, context) async {
    setLoading(true);
    try {
      UserCredential authResult =
          await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SigninPage(),
        ),
      );
      User? user = authResult.user;
      setLoading(true);
      return user;
    } on SocketException {
      setLoading(false);
      setMessage("No internet, please connect to the internet");
    } catch (e) {
      setLoading(false);
      print(e);
      setMessage(e);
    }
    notifyListeners();
  }

  Future login(String email, String password, context) async {
    User? user;

    try {
      setLoading(true);
      UserCredential result = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      user = result.user!;
    } on FirebaseAuthException catch (error) {
      var errorMessage = '';
      switch (error.code) {
        default:
          errorMessage = 'The user you tried to log into was not found.';
          setLoading(false);
          break;
      }
      if (errorMessage.isNotEmpty) {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => MyHomePage()));
        return errorDialog(context, errorMessage);
      }
      setLoading(true);
      return user;
    } finally {
      setLoading(false);
    }
    notifyListeners();
  }

  resetPasswordLink(String email) {
    FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  Future logout() async {
    await firebaseAuth.signOut();
  }

  void setLoading(val) {
    _isLoading = val;
    notifyListeners();
  }

  void setMessage(message) {
    _errorMessage = message.toString();
    notifyListeners();
  }

  Stream<User?> get user =>
      firebaseAuth.authStateChanges().map((event) => event);

  Future<bool?> errorDialog(BuildContext context, e) {
    return showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Text('Login with gmail failed'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 100.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Text(e),
              ),
              Container(
                height: 50.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => SigninPage(),
                          ),
                        );
                      },
                      child: Text(
                        'OK',
                        style: TextStyle(fontSize: 20.0),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
