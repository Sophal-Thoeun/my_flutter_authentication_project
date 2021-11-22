import 'package:flutter/material.dart';
import 'package:flutter_assignment_auth_maps/config/palette.dart';
import 'package:flutter_assignment_auth_maps/service_provider/provider.dart';
import 'package:provider/provider.dart';

class Reset extends StatefulWidget {
  @override
  _ResetState createState() => _ResetState();
}

class _ResetState extends State<Reset> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  late String email;

  @override
  Widget build(BuildContext context) {
    final loginProvider = Provider.of<GmailSignInService>(context);
    return Scaffold(
      backgroundColor: Palette.scaffold,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Palette.scaffold,
        iconTheme: IconThemeData(
          color: Palette.facebookBlue,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      padding: EdgeInsets.fromLTRB(5.0, 100.0, 0.0, 0.0),
                      child: Text(
                        'RESET USER',
                        style: TextStyle(
                          fontSize: 30.0,
                          color: Palette.facebookBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(
                        left: 20.0, top: 50.0, right: 20.0),
                    child: TextFormField(
                      controller: _emailController,
                      onChanged: (value) {
                        this.email = value;
                      },
                      validator: (val) =>
                          val!.isNotEmpty ? null : "Please enter email address",
                      decoration: InputDecoration(
                        labelText: 'EMAIL',
                        prefixIcon: Icon(Icons.mail),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.green),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Container(
                    height: 40.0,
                    padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                    child: Material(
                      borderRadius: BorderRadius.circular(20.0),
                      shadowColor: Colors.blueAccent,
                      color: Palette.facebookBlue,
                      elevation: 7.0,
                      child: InkWell(
                        onTap: () async {
                          if (_formKey.currentState!.validate()) {
                            print("Email: ${_emailController.text}");
                            await loginProvider.resetPasswordLink(
                              email.trim(),
                            );
                            Navigator.of(context).pop();
                            loginProvider.setLoading(false);
                          }
                        },
                        child: Center(
                          child: Text(
                            'RESET',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
