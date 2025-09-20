// ignore_for_file: file_names, prefer_const_constructors, use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'DisplayDataPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScanBarcodePage extends StatefulWidget {
  final DataStore dataStore;

  ScanBarcodePage({required this.dataStore});

  @override
  _ScanBarcodePageState createState() => _ScanBarcodePageState();
}

class _ScanBarcodePageState extends State<ScanBarcodePage> {
  CollectionReference _plistCollection =
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
      body: Column(
        children: [
          Expanded(
            flex: 3, // Image takes up 3/4 of the page
            child: Image.asset('assets/bs.jpg'),
          ),
          Expanded(
            flex: 1, // Text and buttons take up 1/4 of the page
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Choose an Option..',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo[900],
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
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 5,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    primary: Color(0xFFFF725E),
                  ),
                  child: Text('Scan a Barcode', style: TextStyle(fontSize: 18)),
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
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 5,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    primary: Color(0xFFFF725E),
                  ),
                  child: Text('Enter Barcode Manually',
                      style: TextStyle(fontSize: 18)),
                ),
                SizedBox(height: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ManualBarcodeEntryDialog extends StatefulWidget {
  final DataStore dataStore; // Define a dataStore property

  const ManualBarcodeEntryDialog({Key? key, required this.dataStore})
      : super(key: key);

  @override
  ManualBarcodeEntryDialogState createState() =>
      ManualBarcodeEntryDialogState();
}

class ManualBarcodeEntryDialogState extends State<ManualBarcodeEntryDialog> {
  final TextEditingController _barcodeController = TextEditingController();
  CollectionReference _plistCollection =
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
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.qr_code_scanner,
                  size: 36,
                  color: Colors.indigo[900],
                ),
                SizedBox(width: 10),
                Text(
                  'Enter Barcode Number',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo[900],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            TextField(
              controller: _barcodeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Type Barcode Number here',
                labelStyle: TextStyle(
                  color: Colors.indigo[900], // Label text color
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blue, // Border color when not focused
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    String enteredBarcode = _barcodeController.text;
                    if (enteredBarcode.isNotEmpty) {
                      int existingIndex = widget.dataStore.dataList.indexWhere(
                          (data) => data['DocumentID'] == enteredBarcode);
                      if (existingIndex != -1) {
                        // Data is already present, increment quantity
                        widget.dataStore.updateQuantity(existingIndex, 1);
                        _showDataPage(widget.dataStore.dataList);
                      } else {
                        // Data not found in dataList, fetch it from Firestore
                        _plistCollection
                            .doc(enteredBarcode)
                            .get()
                            .then((snapshot) {
                          if (snapshot.exists) {
                            Map<String, dynamic> data =
                                snapshot.data() as Map<String, dynamic>;
                            data['Quantity'] = 1; // Initial quantity
                            data['DocumentID'] =
                                enteredBarcode; // Add DocumentID
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
                      // context,
                      // MaterialPageRoute(
                      //  builder: (context) => DisplayPage(
                      //   dataList: widget.dataStore.dataList,
                      //   dataStore: widget.dataStore,
                      // ),
                      // ),
                      // );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFFFF725E),
                    onPrimary: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                  child: const Text('Add'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFFFF725E),
                    onPrimary: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
