// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, file_names, library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:weigh/ScanBarcodePage.dart';

import 'DisplayDataPage.dart';
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
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            ScanBarcodePage(
                          dataStore: DataStore(),
                        ), // Replace SecondPage() with your SecondPage
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          const begin = Offset(1.0, 0.0);
                          const end = Offset.zero;
                          const curve = Curves.easeInOut;
                          var tween = Tween(begin: begin, end: end).chain(
                            CurveTween(curve: curve),
                          );
                          var offsetAnimation = animation.drive(tween);
                          return SlideTransition(
                            position: offsetAnimation,
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                  icon: Icon(Icons.arrow_forward),
                  label: Text(''),
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFFFF725E),
                    padding: EdgeInsets.all(15),
                    shape: CircleBorder(),
                    elevation: 5.0,
                    alignment: Alignment.center,
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
