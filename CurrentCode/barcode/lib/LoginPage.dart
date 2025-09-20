// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace, deprecated_member_use, library_private_types_in_public_api, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, file_names, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'WelcomePage.dart';
import 'GlobalData.dart';

class LoginPage extends StatefulWidget {
  LoginPage({this.cartNumber});

  @override
  _LoginPageState createState() => _LoginPageState();

  final String? cartNumber;
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (widget.cartNumber != null &&
                widget.cartNumber!.isNotEmpty) // Use GlobalData.cartNumber
              Text(
                'Cart Number: ${GlobalData.cartNumber}',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              )
            else
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
                    'Hello',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Enter your Name'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _phoneNumberController,
              decoration: InputDecoration(labelText: 'Enter your Phone Number'),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 20),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  String enteredName = _nameController.text;
                  String enteredPhoneNumber =
                      "+91${_phoneNumberController.text}";
                  GlobalData.userName = enteredName;
                  GlobalData.phoneNumber = enteredPhoneNumber;
                  // Upload phone number to Firebase Realtime Database

                  // Navigate to the WelcomePage with the entered data.
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WelcomePage(
                        userName: enteredName,
                        phoneNumber: enteredPhoneNumber,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.grey[300],
                  onPrimary: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                  elevation: 5,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
                child: Text(
                  'Submit',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
