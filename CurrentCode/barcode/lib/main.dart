// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'CartNumberPage.dart';
import 'PhoneEntryPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MaterialApp(
      title: 'Barcode App',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      initialRoute: '/signup', // Start with the SignupPage.
      routes: {
        '/signup': (context) => PhoneEntryPage(), // SignupPage route.
        '/cartnumber': (context) => CartNumberPage(),
      },
    ),
  );
}
