// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, file_names, library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'LoginPage.dart'; // Import the QR code scanner package.
import 'GlobalData.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan Cart Number'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                'Received Cart Number: $cartNumberz', // Display the scanned cart number.
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Navigate to the login page with the cart number.
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            LoginPage(cartNumber: GlobalData.cartNumber),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          20), // Adjust the border radius as needed
                      side:
                          BorderSide(color: Colors.grey[300]!), // Border color
                    ),
                    elevation: 5, // Elevation (shadow)
                    padding: EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15), // Padding
                    primary: Colors.grey[300], // Button background color
                  ),
                  child: Text(
                    'Proceed',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
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
