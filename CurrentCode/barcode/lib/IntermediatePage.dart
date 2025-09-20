// ignore_for_file: file_names, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, library_private_types_in_public_api, prefer_final_fields, deprecated_member_use, use_build_context_synchronously, avoid_print, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'thank_you_page.dart';
import 'GlobalData.dart';

class IntermediatePage extends StatefulWidget {
  final String pdfFileName;
  final String phoneNumber;

  IntermediatePage({required this.pdfFileName, required this.phoneNumber});

  @override
  _IntermediatePageState createState() => _IntermediatePageState();
}

class _IntermediatePageState extends State<IntermediatePage> {
  DatabaseReference _databaseReference = FirebaseDatabase.instance.reference();
  String statusMessage = ''; // Added a variable to store status message
  String status = "Unknown";
  @override
  void initState() {
    super.initState();

    // Start listening to changes in the 'Status' for GlobalData.cartNumber
    _databaseReference
        .child('Status/${GlobalData.cartNumber}')
        .onValue
        .listen((event) {
      dynamic status = event.snapshot.value;

      if (status != null && status is String) {
        setState(() {
          this.status = status; // Update the status variable
        });

        if (status == "Weights Matched") {
          // If status is "Weights Matched," navigate to ThankYouPage
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => ThankYouPage(
                pdfFileName: widget.pdfFileName,
                phoneNumber: widget.phoneNumber,
              ),
            ),
          );
        } else if (status == "Weights Not Matched") {
          // If status is "Weights not Matched," set the statusMessage accordingly
          setState(() {
            statusMessage = 'Please Check your Products';
          });
        }
      } else {
        // Handle other cases if needed
        print('Invalid status type or status is null: $status');
      }
    });
  }

  @override
  void dispose() {
    // Dispose the database reference when the widget is disposed
    _databaseReference.child('Status/${GlobalData.cartNumber}').onValue.drain();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 100.0,
              width: 100.0,
              child: CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(
                  Icons.check_circle,
                  size: 48,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Payment Successful',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 40),
            Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.shopping_cart,
                      size: 48,
                      color: Colors.black,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Go to Exit Counter and place your cart',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 100),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    statusMessage,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
                SizedBox(height: 20), // Add spacing between the text and button
                if (status == "Weights Not Matched")
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context)
                          .popUntil(ModalRoute.withName('/list'));
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      elevation: 5,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      primary: Colors.grey[300],
                    ),
                    child: Text(
                      'Go to Scanned Products',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
              ],
            ),
            Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => ThankYouPage(
                        pdfFileName: widget.pdfFileName,
                        phoneNumber: widget.phoneNumber,
                      ),
                    ),
                  );
                },
                child: Text(
                  'Skip',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    decoration: TextDecoration.underline,
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
