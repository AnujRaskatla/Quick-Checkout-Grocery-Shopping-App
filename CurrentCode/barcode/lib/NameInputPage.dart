// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, file_names, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'GlobalData.dart'; // Import the necessary files

class NameInputPage extends StatefulWidget {
  @override
  _NameInputPageState createState() => _NameInputPageState();
}

class _NameInputPageState extends State<NameInputPage> {
  TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Your Name'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Enter your name',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String name = nameController.text.trim();
                if (name.isNotEmpty) {
                  // Save the name to GlobalData for later use
                  GlobalData.userName = name;
                  Navigator.of(context).pushReplacementNamed('/cartnumber');
                } else {
                  // Show an error message or handle empty name input
                }
              },
              child: Text('Proceed to Cart Number'),
            ),
          ],
        ),
      ),
    );
  }
}
