// ignore_for_file: file_names, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, library_private_types_in_public_api, prefer_final_fields, deprecated_member_use, use_build_context_synchronously, avoid_print, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'thank_you_page.dart';
import 'GlobalData.dart';
import 'DisplayDataPage.dart';
import 'package:google_fonts/google_fonts.dart';

class IntermediatePage extends StatefulWidget {
  final DataStore dataStore;
  final List<Map<String, dynamic>> dataList;
  IntermediatePage({required this.dataStore, required this.dataList});

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
              builder: (context) => ThankYouPage(),
            ),
          );
        } else if (status == "Weights Not Matched") {
          // If status is "Weights not Matched," set the statusMessage accordingly
          setState(() {
            statusMessage =
                'Remove the cart from counter and Please Check your Products';
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
        padding: const EdgeInsets.all(0.0),
        child: Column(
          //  mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height *
                  0.60, // Adjust the height as needed
              child: Image.asset('assets/ct.jpg'),
            ),
            if (status != "Weights Matched" && status != "Weights Not Matched")
              Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Go to Exit Counter and place your cart',
                        style: GoogleFonts.roboto(
                          textStyle: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            SizedBox(height: 30),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
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
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => DisplayPage(
                          dataList: widget.dataList,
                          dataStore: widget.dataStore),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  shape: CircleBorder(),
                  primary: Colors.red[600], // Change the color as needed
                ),
                child: SizedBox(
                  width: 60, // Adjust the width of the circular button
                  height: 60, // Adjust the height of the circular button
                  child: Center(
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),

            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => ThankYouPage(),
                    ),
                  );
                },
                child: Text(
                  'Skip',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[300],
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
