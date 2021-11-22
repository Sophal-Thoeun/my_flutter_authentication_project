import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_assignment_auth_maps/config/palette.dart';
import 'package:flutter_assignment_auth_maps/main.dart';
import 'package:flutter_assignment_auth_maps/pages/export_pages.dart';

enum MobileVerificationState {
  SHOW_MOBILE_FORM_STATE,
  SHOW_OTP_FORM_STATE,
}

class PhoneAuthPage extends StatefulWidget {
  @override
  _PhoneAuthPageState createState() => _PhoneAuthPageState();
}

class _PhoneAuthPageState extends State<PhoneAuthPage> {
  MobileVerificationState currentState =
      MobileVerificationState.SHOW_MOBILE_FORM_STATE;

  final phoneController = TextEditingController();
  final otpController = TextEditingController();
  late String verificationId;
  bool showLoading = false;
  bool showMessage = false;
  final _formKey = GlobalKey<FormState>();

  FirebaseAuth _auth = FirebaseAuth.instance;

  void signInWithPhoneAuthCredential(
      PhoneAuthCredential phoneAuthCredential) async {
    setState(() {
      showLoading = true;
    });
    try {
      final authCredential =
          await _auth.signInWithCredential(phoneAuthCredential);
      setState(() {
        showLoading = false;
      });
      if (authCredential.user != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GoogleMapSample(),
          ),
        );
      }
    } on FirebaseException catch (e) {
      setState(() {
        showLoading = false;
      });
      _scaffoldKey.currentState!.showSnackBar(
        SnackBar(
          content: Text(
            e.message.toString(),
          ),
        ),
      );
    }
  }

  getMobileFormWidget(context) {
     return Form(
      key: _formKey,
      child: Column(
        children: [
          Spacer(),
          Text(
            "SIGN UP",
            style: TextStyle(
              fontSize: 50.0,
              fontWeight: FontWeight.bold,
              color: Palette.facebookBlue,
            ),
          ),
          const SizedBox(height: 40.0),
          Container(
            padding: const EdgeInsets.only(left: 10.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              border: Border.all(
                color: Palette.facebookBlue,
              ),
            ),
            child: TextFormField(
              keyboardType: TextInputType.number,
              controller: phoneController,
              decoration: InputDecoration(
                hintText: '+855 Enter Phone Number',
                border: InputBorder.none,
              ),
              style: TextStyle(fontSize: 18.0),
            ),
          ),
          const SizedBox(height: 16.0),
          FlatButton(
            onPressed: () async {
              if (phoneController.text.isEmpty) {
                print('Please enter phone number');
                bool shouldUpdate = await showDialog(
                  context: this.context,
                  builder: (BuildContext context) {
                    return new AlertDialog(
                      content: new FlatButton(
                        child: new Text("Phone Number cannot be blank, "
                            "Make sure you entered correctly number."),
                        onPressed: () => Navigator.pop(context, true),
                      ),
                    );
                  },
                );
              } else {
                setState(() {
                  showLoading = true;
                });
                await _auth.verifyPhoneNumber(
                  phoneNumber: phoneController.text,
                  verificationCompleted: (phoneAuthCredential) async {
                    setState(() {
                      showLoading = false;
                    });
                  },
                  verificationFailed: (verificationFailed) async {
                    setState(() {
                      showLoading = false;
                    });
                    _scaffoldKey.currentState!.showSnackBar(
                      SnackBar(
                        content: Text(verificationFailed.message.toString()),
                      ),
                    );
                  },
                  codeSent: (verificationId, resendingToken) async {
                    setState(() {
                      showLoading = false;
                      currentState =
                          MobileVerificationState.SHOW_OTP_FORM_STATE;
                      this.verificationId = verificationId;
                    });
                  },
                  codeAutoRetrievalTimeout: (verificationId) async {},
                );
              }
            },
            child: Container(
              padding: EdgeInsets.only(left: 20.0, right: 20.0),
              height: 40.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                color: Palette.facebookBlue,
              ),
              child: Center(
                child: Text(
                  'SEND',
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ),
            ),
            textColor: Colors.white,
          ),
          Spacer(),
        ],
      ),
    );
  }

  getOtpFormWidget(context) {
    return Column(
      children: [
        Spacer(),
        Text(
          "OTP Number",
          style: TextStyle(
            fontSize: 50.0,
            fontWeight: FontWeight.bold,
            color: Palette.facebookBlue,
          ),
        ),
        const SizedBox(height: 40.0),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1.0,
                width: MediaQuery.of(context).size.width - 40.0,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 4.0),
            Text(
              ' 6 digits OTP Number ',
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
            const SizedBox(width: 4.0),
            Expanded(
              child: Container(
                height: 1.0,
                width: MediaQuery.of(context).size.width - 40.0,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 40.0),
        Container(
          padding: const EdgeInsets.only(left: 10.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            border: Border.all(
              color: Palette.facebookBlue,
            ),
          ),
          child: TextField(
            controller: otpController,
            decoration: InputDecoration(
              hintText: 'Enter OTP Number',
            ),
          ),
        ),
        const SizedBox(height: 16.0),
        FlatButton(
          onPressed: () async {
            if (otpController.text.isEmpty) {
              print('OTP cannot be blank');
              bool shouldUpdate = await showDialog(
                context: this.context,
                builder: (BuildContext context) {
                  return new AlertDialog(
                    content: new FlatButton(
                      child: Row(
                        children: [
                          Icon(
                            Icons.error,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 10.0),
                          new Text("OTP Number cannot be blank"),
                        ],
                      ),
                      onPressed: () => Navigator.pop(context, true),
                    ),
                  );
                },
              );
            } else {
              setState(() {
                showLoading = true;
              });
              PhoneAuthCredential phoneAuthCredential =
                  PhoneAuthProvider.credential(
                verificationId: verificationId,
                smsCode: otpController.text,
              );
              signInWithPhoneAuthCredential(phoneAuthCredential);
            }
          },
          child: Text('VERIFY'),
          color: Colors.blue,
          textColor: Colors.white,
        ),
        Spacer(),
      ],
    );
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Palette.scaffold,
        iconTheme: IconThemeData(
          color: Palette.facebookBlue,
        ),
      ),
      body: Container(
        color: Palette.scaffold,
        padding: const EdgeInsets.all(20.0),
        child: showLoading
            ? Center(child: CircularProgressIndicator())
            : currentState == MobileVerificationState.SHOW_MOBILE_FORM_STATE
                ? getMobileFormWidget(context)
                : getOtpFormWidget(context),
      ),
    );
  }
}

class InitializerWidget extends StatefulWidget {
  @override
  _InitializerWidgetState createState() => _InitializerWidgetState();
}

class _InitializerWidgetState extends State<InitializerWidget> {
  late FirebaseAuth _auth;
  User? _user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _auth = FirebaseAuth.instance;
    _user = _auth.currentUser!;
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Scaffold(
            appBar: AppBar(),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : _user == null
            ? MyHomePage()
            : GoogleMapSample();
  }
}
