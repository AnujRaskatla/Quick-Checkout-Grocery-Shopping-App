// ignore_for_file: file_names, prefer_const_constructors, deprecated_member_use, prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:weigh/ScanBarcodePage.dart';
import 'DisplayDataPage.dart';

class WelcomePage extends StatelessWidget {
  final String userName;
  final String phoneNumber;
  final cartNumber;

  const WelcomePage({
    Key? key,
    required this.userName,
    required this.phoneNumber,
    required this.cartNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      'assets/ac.jpg'), // Replace with your image path
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Welcome, $userName!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 8),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.indigo[900], // Customize the bubble color
                      ),
                      child: Text(
                        '$cartNumber',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width -
                        40, // 20 on either side
                  ),
                  child: Text(
                    'To add items to your cart, Scan the Barcode on the product by pressing the below button',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            ScanBarcodePage(
                          dataStore: DataStore(),
                        ), // Replace with your ScanPage
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
                  icon: Icon(
                    Icons.arrow_forward,
                    color: Colors.black, // Icon color
                  ),
                  label: Text(''),
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFFFF725E),
                    padding: EdgeInsets.all(15),
                    shape: CircleBorder(),
                    elevation: 5.0,
                    alignment: Alignment.center,
                  ),
                ),
                SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
