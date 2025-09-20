// ignore_for_file: use_build_context_synchronously, avoid_print, prefer_is_empty, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'LoginPage.dart';
import 'ScannedItemsModel.dart';
import 'ScanBarcodePage.dart';
import 'ViewListPage.dart';
import 'CartNumberPage.dart';
import 'GlobalData.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider(
      create: (context) => ScannedItemsModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barcode App',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      initialRoute: '/cartnumber', // Start with the CartNumberPage.
      routes: {
        '/cartnumber': (context) => CartNumberPage(), // CartNumberPage route.
        '/login': (context) => LoginPage(), // LoginPage route.
        '/scan': (context) => ScanBarcodePage(),
        '/list': (context) => ViewListPage(
              scannedItemsModel: Provider.of<ScannedItemsModel>(context),
              phoneNumber: GlobalData.phoneNumber,
            ),
      },
    );
  }
}
