// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'ScannedItemsModel.dart';
import 'ScanBarcodePage.dart';
import 'ViewListPage.dart';
import 'CartNumberPage.dart';
import 'GlobalData.dart';
import 'PhoneEntryPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider(
      create: (context) => ScannedItemsModel(),
      child: MaterialApp(
        title: 'Barcode App',
        theme: ThemeData(
          primarySwatch: Colors.grey,
        ),
        initialRoute: '/signup', // Start with the SignupPage.
        routes: {
          '/signup': (context) => PhoneEntryPage(), // SignupPage route.
          '/cartnumber': (context) => CartNumberPage(), // CartNumberPage route.
          '/scan': (context) => ScanBarcodePage(),
          '/list': (context) => ViewListPage(
                scannedItemsModel: Provider.of<ScannedItemsModel>(context),
                phoneNumber: GlobalData.phoneNumber,
              ),
        },
      ),
    ),
  );
}
