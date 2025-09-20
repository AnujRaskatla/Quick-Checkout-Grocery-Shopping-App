// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, file_names, library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:weigh/ScanBarcodePage.dart';

import 'PhoneEntryPage.dart';
import 'GlobalData.dart';
import 'DisplayDataPage.dart';

class CartNumberPage extends StatefulWidget {
  @override
  _CartNumberPageState createState() => _CartNumberPageState();
}

class _CartNumberPageState extends State<CartNumberPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late QRViewController controller;

  String? cartNumberz = ''; // Global cart number variable.

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ThirdPage(), // Replace with your ThirdPage widget
          ),
        );
        return false; // Prevent the default back button behavior
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 4,
          backgroundColor: Colors.white,
          title: Text(
            'Scan QR',
            style: TextStyle(
              color: Colors.indigo[900],
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              flex: 3, // Scanner screen takes up 3/4 of the page
              child: QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
              ),
            ),
            Expanded(
              flex: 1, // Cart Number and Proceed button take up 1/4 of the page
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Received Cart Number: $cartNumberz',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo[900]),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to the new page here
                      // You can use Navigator.push to navigate to the new page
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ScanBarcodePage(
                            dataStore: DataStore(),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      primary: Colors.orange[900], // Change the color as needed
                    ),
                    child: SizedBox(
                      width: 60, // Adjust the width of the circular button
                      height: 60, // Adjust the height of the circular button
                      child: Center(
                        child: Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        cartNumberz = scanData.code;
        GlobalData.cartNumber = scanData.code;
      });
    });
  }
}
