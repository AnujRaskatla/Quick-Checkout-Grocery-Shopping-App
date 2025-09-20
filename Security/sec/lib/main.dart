// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, deprecated_member_use, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CounterDetailsPage()),
            );
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Colors.grey[300]!),
            ),
            elevation: 5,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            primary: Colors.grey[300],
          ),
          child: Text('Open Counter Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              )),
        ),
      ),
    );
  }
}

class CounterDetailsPage extends StatefulWidget {
  @override
  _CounterDetailsPageState createState() => _CounterDetailsPageState();
}

class _CounterDetailsPageState extends State<CounterDetailsPage> {
  final DatabaseReference _counterDetailsRef = FirebaseDatabase.instance
      .reference()
      .child('CounterDetails/Counter Number 2');

  Map<String, dynamic>? _counterData;

  Map<String, dynamic> _dynamicToMap(dynamic value) {
    return Map<String, dynamic>.from(value);
  }

  @override
  void initState() {
    super.initState();

    // Listen for changes to the Firebase Realtime Database
    _counterDetailsRef.onValue.listen((event) {
      final dynamic data = event.snapshot.value;
      if (data != null) {
        setState(() {
          _counterData = _dynamicToMap(data);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: const Text(
          'Counter Details:',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _counterData != null
          ? SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ListTile(
                        title: Text(
                          'Counter Number: 2',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 20.0),
                      _buildDetailRow(
                          'Cart Number', _counterData!['CartNumber']),
                      _buildComparisonResultRow(
                          _counterData!['ComparisonResult']),
                      _buildDetailRow(
                          'Difference', _counterData!['Difference']),
                      _buildDetailRow(
                          'Total Weight', _counterData!['TotalWeight']),
                      _buildDetailRow('Weight Value',
                          _formatDecimal(_counterData!['WeightValue'])),
                    ],
                  ),
                ),
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
          Text(
            _formatDynamic(value), // Format numbers to have one decimal place
            style: TextStyle(fontSize: 16.0),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonResultRow(String comparisonResult) {
    final isMatched = comparisonResult == 'Weights Matched';
    final textColor = isMatched ? Colors.green : Colors.red;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            'Comparison Result',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
          Text(
            comparisonResult,
            style: TextStyle(
              fontSize: 16.0,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDecimal(dynamic value) {
    if (value is String) {
      return double.tryParse(value)?.toStringAsFixed(1) ?? value.toString();
    } else if (value is num) {
      return value.toStringAsFixed(1);
    }
    return value.toString();
  }

  String _formatDynamic(dynamic value) {
    if (value is String) {
      return _formatDecimal(value);
    } else if (value is num) {
      return _formatDecimal(value);
    }
    return value.toString();
  }
}
