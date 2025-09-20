// cartnumber/CartNumberPage.dart

// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, file_names, library_private_types_in_public_api

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
        title: Text('Cart Number'),
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
                'Cart Number: $cartNumberz', // Display the scanned cart number.
                style: TextStyle(fontSize: 18),
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
                  child: Text('Enter Cart Number'),
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
