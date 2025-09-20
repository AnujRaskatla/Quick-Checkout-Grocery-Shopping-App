// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, prefer_final_fields, deprecated_member_use, prefer_const_constructors, avoid_print

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: QRCodePage(),
    );
  }
}

class QRCodePage extends StatefulWidget {
  @override
  _QRCodePageState createState() => _QRCodePageState();
}

class _QRCodePageState extends State<QRCodePage> {
  TextEditingController phoneNumberController = TextEditingController();
  DatabaseReference _databaseReference = FirebaseDatabase.instance.reference();

  String qrCodeData = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Generator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: phoneNumberController,
              decoration: InputDecoration(
                labelText: 'Enter Phone Number',
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Retrieve real-time weight data from Firebase using entered phone number
                String phoneNumber = phoneNumberController.text;

                try {
                  DatabaseEvent event = await _databaseReference
                      .child('phoneNumbers/$phoneNumber/totalWeight')
                      .once();

                  DataSnapshot snapshot = event.snapshot;

                  double weight = snapshot.value != null
                      ? double.parse(snapshot.value.toString())
                      : 0.0;

                  // Generate QR code with weight data
                  setState(() {
                    qrCodeData = 'Phone Number: $phoneNumber\nWeight: $weight';
                  });
                } catch (e) {
                  print('Error retrieving data from Firebase: $e');
                }
              },
              child: Text('Generate QR Code'),
            ),
            SizedBox(height: 20.0),
            if (qrCodeData.isNotEmpty)
              QrImageView(
                data: qrCodeData,
                version: QrVersions.auto,
                size: 200.0,
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    phoneNumberController.dispose();
    super.dispose();
  }
}
