// ignore_for_file: prefer_const_constructors, file_names, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'WelcomePage.dart';

class GlobalData {
  static String userName = '';
  static String phoneNumber = '';
}

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  @override
  void dispose() {
    _phoneNumberController.dispose(); // Dispose of the controller
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
            Text(
              'Hello',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
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
            ElevatedButton(
              onPressed: () {
                String enteredName = _nameController.text;
                String enteredPhoneNumber = _phoneNumberController.text;

                // Assign the entered values to the global variables
                GlobalData.userName = enteredName;
                GlobalData.phoneNumber = enteredPhoneNumber;

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WelcomePage(
                        userName: enteredName, phoneNumber: enteredPhoneNumber),
                  ),
                );
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
