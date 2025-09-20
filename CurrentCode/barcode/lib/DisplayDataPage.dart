// ignore_for_file: file_names, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, library_private_types_in_public_api, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DisplayDataPage extends StatefulWidget {
  final String barcode;

  DisplayDataPage({required this.barcode});

  @override
  _DisplayDataPageState createState() => _DisplayDataPageState();
}

class _DisplayDataPageState extends State<DisplayDataPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data for Barcode: ${widget.barcode}'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('PList')
            .doc(widget.barcode)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            return Text('No data found for barcode: ${widget.barcode}');
          } else {
            // Parse and display Firestore data here
            Map<String, dynamic> data =
                snapshot.data!.data() as Map<String, dynamic>;

            return ListView.builder(
              shrinkWrap: true,
              itemCount: 1, // If you have multiple items, change this.
              itemBuilder: (context, index) {
                return DisplayDataWidget(data: data); // Use the new widget here
              },
            ); // Use the new widget here
          }
        },
      ),
    );
  }
}

class DisplayDataWidget extends StatefulWidget {
  final Map<String, dynamic> data;

  DisplayDataWidget({required this.data});

  @override
  _DisplayDataWidgetState createState() => _DisplayDataWidgetState();
}

class _DisplayDataWidgetState extends State<DisplayDataWidget> {
  @override
  Widget build(BuildContext context) {
    int quantity = widget.data['Quantity'] ?? 1;
    double totalPrice = widget.data['Price'] * quantity.toDouble();
    double totalWeight = widget.data['Weight'] * quantity.toDouble();

    return Container(
      margin: EdgeInsets.symmetric(vertical: 2),
      padding: EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                ' ${widget.data['Name']}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '(₹) ${totalPrice.toStringAsFixed(2)} ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    '  (${widget.data['Barcode_Number']})',
                  ),
                  Text(
                    '(${totalWeight.toStringAsFixed(2)})',
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            // Implement your decrement logic here
                            // You can use the 'quantity' variable and update it accordingly
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '-',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Text(' $quantity ', style: TextStyle(fontSize: 18)),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            // Implement your increment logic here
                            // You can use the 'quantity' variable and update it accordingly
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '+',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
