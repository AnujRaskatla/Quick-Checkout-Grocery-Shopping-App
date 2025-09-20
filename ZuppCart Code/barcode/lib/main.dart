import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'CartNumberPage.dart';
import 'PhoneEntryPage.dart';
import 'ThirdPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final FlutterSecureStorage storage = FlutterSecureStorage();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  String? token = await storage.read(key: 'auth_token');

  runApp(
    MaterialApp(
      title: 'Barcode App',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      initialRoute: (token != null) ? '/thirdPage' : '/signup',
      routes: {
        '/signup': (context) => PhoneEntryPage(),
        '/cartnumber': (context) => CartNumberPage(),
        '/thirdPage': (context) => ThirdPage(),
      },
    ),
  );
}
