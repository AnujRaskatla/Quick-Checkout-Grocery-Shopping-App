// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, file_names, library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import 'GlobalData.dart';
import 'WelcomePage.dart';

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
                ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to the WelcomePage directly with the cart number, name, and phone number.
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WelcomePage(
                          cartNumber: GlobalData.cartNumber,
                          userName: GlobalData.userName,
                          phoneNumber: GlobalData.phoneNumber,
                        ),
                      ),
                    );
                  },
                  icon: Icon(Icons.arrow_forward),
                  label: Text(''),
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFFFF914D),
                    padding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    elevation: 5.0,
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
