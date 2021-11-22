import 'package:flutter/material.dart';

class SignUpWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildSignUp(),
    );
  }
}

Widget buildSignUp() {
  return Column(
    children: [
      Spacer(),
      Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20.0),
          width: 175.0,
          child: Text(
            'Welcome to Google Maps',
            style: TextStyle(
              color: Colors.black,
              fontSize: 30.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      Spacer(),
      const SizedBox(height: 12.0),
      Text(
        'Login to continue',
        style: TextStyle(
          fontSize: 16.0,
        ),
      ),
      Spacer(),
    ],
  );
}
