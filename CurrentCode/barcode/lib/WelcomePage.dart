// ignore_for_file: file_names, prefer_const_constructors, deprecated_member_use

import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  final String userName;
  final String phoneNumber;

  const WelcomePage({
    Key? key,
    required this.userName,
    required this.phoneNumber,
    String? cartNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_circle,
                  size: 48,
                  color: Colors.black,
                ),
                SizedBox(width: 10),
                Text(
                  'Welcome, $userName!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Let\'s Add Products to your Cart!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/scan'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.grey[300]!),
                ),
                elevation: 5,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                primary: Colors.grey[300],
              ),
              child: Text('Scan Barcode', style: TextStyle(fontSize: 18)),
            ),
            SizedBox(height: 10),
            // Add a SizedBox to push the "Skip" text to the bottom right corner
            SizedBox(height: 200),
            Align(
              alignment: Alignment.bottomRight,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/list',
                    arguments: {'phoneNumber': phoneNumber},
                  );
                },
                child: Text(
                  'Skip',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[300], // You can customize the color
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
