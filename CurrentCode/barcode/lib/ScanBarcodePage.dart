// ignore_for_file: file_names, prefer_const_constructors, use_build_context_synchronously, deprecated_member_use, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, library_private_types_in_public_api, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import 'DisplayDataPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'GlobalData.dart';
import 'ManualBarcodeEntryDialog.dart';

class ScanBarcodePage extends StatefulWidget {
  final DataStore dataStore;

  ScanBarcodePage({
    required this.dataStore,
  });

  @override
  _ScanBarcodePageState createState() => _ScanBarcodePageState();
}

class _ScanBarcodePageState extends State<ScanBarcodePage> {
  final CollectionReference _plistCollection =
      FirebaseFirestore.instance.collection('PList');
  void _showDataPage(List<Map<String, dynamic>> dataList) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            DisplayPage(dataList: dataList, dataStore: widget.dataStore),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        // Use ListView for scrolling
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.of(context)
                          .pop(); // Go back to the previous page
                    },
                  ),
                  Text(
                    'Go back to Cart Scan',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Adjust the height as needed
          Image.asset('assets/bs.jpg'),

          Padding(
            padding: const EdgeInsets.all(50.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Welcome, ${GlobalData.userName}!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 8),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.indigo[900], // Customize the bubble color
                      ),
                      child: Text(
                        '${GlobalData.cartNumber}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  'Scan a Barcode of a Product to add to Shopping list',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    String barcode = await FlutterBarcodeScanner.scanBarcode(
                      '#FF0000',
                      'Cancel',
                      true,
                      ScanMode.BARCODE,
                    );
                    if (barcode.isNotEmpty) {
                      int existingIndex = widget.dataStore.dataList
                          .indexWhere((data) => data['DocumentID'] == barcode);
                      if (existingIndex != -1) {
                        // Data is already present, increment quantity
                        widget.dataStore.updateQuantity(existingIndex, 1);
                        _showDataPage(widget.dataStore.dataList);
                      } else {
                        // Data not found in dataList, fetch it from Firestore
                        _plistCollection.doc(barcode).get().then((snapshot) {
                          if (snapshot.exists) {
                            Map<String, dynamic> data =
                                snapshot.data() as Map<String, dynamic>;
                            data['Quantity'] = 1; // Initial quantity
                            data['DocumentID'] = barcode; // Add DocumentID
                            widget.dataStore
                                .addData(data); // Add the data to DataStore
                            _showDataPage(widget.dataStore.dataList);
                          } else {
                            // Document not found
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Document not found'),
                              ),
                            );
                          }
                        }).catchError((error) {
                          // Handle errors if needed
                          print('Error fetching document: $error');
                        });
                      }
                      // Navigator.push(
                      //context,
                      // MaterialPageRoute(
                      //  builder: (context) => DisplayPage(
                      //  dataList: widget.dataStore.dataList,
                      //  dataStore: widget.dataStore,
                      // ),
                      // ),
                      // );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                    elevation: 5,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    primary: Colors.orange[900],
                  ),
                  child: Text(
                    'Scan Barcode',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return ManualBarcodeEntryDialog(
                          dataStore: widget.dataStore,
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                    elevation: 5,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    primary: Colors.orange[900],
                  ),
                  child: Text('Enter Barcode No.',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
