import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_assignment_auth_maps/pages/export_pages.dart';
import 'package:flutter_assignment_auth_maps/service_provider/facebook_sign_in_service.dart';
import 'package:flutter_assignment_auth_maps/service_provider/google_sign_in_service.dart';
import 'package:flutter_assignment_auth_maps/service_provider/gmail_sign_in_service.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<GmailSignInService>.value(value: GmailSignInService()),
        ChangeNotifierProvider<FacebookSignInService>.value(value: FacebookSignInService()),
        ChangeNotifierProvider(
          create: (context) => GoogleSignInService(),
          child: StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              final provider = Provider.of<GoogleSignInService>(context,listen: false);
              if (provider.isSigningIn) {
                return buildLoading();
              } else if (snapshot.hasData) {
                return GoogleMapSample();
              } else {
                return SigninPage();
              }
            },
          ),
        ),
        StreamProvider<User?>.value(
          value: GmailSignInService().user,
          initialData: null,
        ),
      ],
      child: MaterialApp(
        home: MyHomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

Widget buildLoading() => Center(child: CircularProgressIndicator());

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: InitializerWidget(),
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
    _user = _auth.currentUser;
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : _user == null
            ? SigninPage()
            : GoogleMapSample();
  }
}
