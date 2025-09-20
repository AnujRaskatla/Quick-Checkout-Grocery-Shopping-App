// ignore_for_file: file_names

import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  final String userName;
  final String phoneNumber;

  const WelcomePage({
    Key? key,
    required this.userName,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome $userName,',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/scan'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.grey[300],
              ),
              child: const Text('Scan Barcode'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(
                context,
                '/list',
                arguments: {'phoneNumber': phoneNumber},
              ),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.grey[300],
              ),
              child: const Text('View List'),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
