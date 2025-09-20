// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, file_names, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:weigh/IntermediatePage.dart';
import 'DisplayDataPage.dart';

class RefundPage extends StatefulWidget {
  final List<Map<String, dynamic>> dataList;
  final DataStore dataStore;
  RefundPage({required this.dataStore, required this.dataList});
  @override
  RefundPageState createState() => RefundPageState();
}

class RefundPageState extends State<RefundPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.60,
            child: Image.asset('assets/rf.jpg'),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              // Add SingleChildScrollView to allow scrolling
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Refund Initiated',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  'Press on the below button to Complete your Checkout',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to the new page here
                    // You can use Navigator.push to navigate to the new page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => IntermediatePage(
                            dataList: widget.dataList,
                            dataStore: widget.dataStore),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    primary: Colors.blue[800], // Change the color as needed
                  ),
                  child: SizedBox(
                    width: 60, // Adjust the width of the circular button
                    height: 60, // Adjust the height of the circular button
                    child: Center(
                      child: Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
