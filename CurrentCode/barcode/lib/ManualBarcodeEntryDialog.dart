// ignore_for_file: prefer_const_constructors, file_names, avoid_print, deprecated_member_use

import 'package:flutter/material.dart';

import 'DisplayDataPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
                        //_showDataPage(widget.dataStore.dataList);
                        //Navigator.push(
                        //  context,
                        //  MaterialPageRoute(
                        //   builder: (context) => DisplayPage(
                        //    dataList: widget.dataStore.dataList,
                        //    dataStore: widget.dataStore,
                        //  ),
                        //  ),
                        //  );
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

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DisplayPage(
                            dataList: widget.dataStore.dataList,
                            dataStore: widget.dataStore,
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.orange[900],
                    onPrimary: Colors.white,
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
                    primary: Colors.orange[900],
                    onPrimary: Colors.white,
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
