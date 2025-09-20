// main.dart
// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors_in_immutables, prefer_const_constructors, library_private_types_in_public_api, prefer_final_fields, avoid_print, deprecated_member_use, file_names, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'GlobalData.dart';
import 'ScanBarcodePage.dart';
import 'PaymentPage.dart';
import 'pdf.dart';

class DataStore {
  List<Map<String, dynamic>> dataList = [];

  void addData(Map<String, dynamic> data) {
    dataList.add(data);
  }

  void updateQuantity(int index, int value) {
    dataList[index]['Quantity'] += value;
    if (dataList[index]['Quantity'] < 1) {
      dataList[index]['Quantity'] = 1;
    }
  }
}

class DisplayPage extends StatefulWidget {
  final List<Map<String, dynamic>> dataList;
  final DataStore dataStore;

  DisplayPage({required this.dataList, required this.dataStore});

  @override
  _DisplayPageState createState() => _DisplayPageState();
}

class _DisplayPageState extends State<DisplayPage> {
  double totalPrice = 0.0;
  bool _isDeleting = false;
  List<int> _selectedIndices = [];
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.reference();

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

  Future<void> updateTotalWeightInDatabase(double totalWeight) async {
    try {
      // Upload total weight to Firebase Realtime Database under the corresponding cartNumber
      await _databaseReference
          .child(
              'cartNumbers/${GlobalData.cartNumber}/totalWeight') // Use cartNumber
          .set(totalWeight);
      print('Total Weight uploaded to the database: $totalWeight');
    } catch (e) {
      print('Failed to upload Total Weight to the database: $e');
    }
  }

  Future<void> _showConfirmationDialog() async {
    bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0), // Rounded corners
          ),
          title: Text('Confirm'),
          content: Text('Do you want to end your shopping?'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.of(context)
                    .pop(true); // Return true when "Yes" is pressed.
                await PDFGenerator.generatePDF(widget.dataList);
              },
              child: Container(
                padding: EdgeInsets.all(10.0), // Add padding
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                      30.0), // Rounded corners for buttons
                  border: Border.all(color: Colors.red),
                  color: Colors.orange[900], // Border
                ),
                child: Text(
                  'Yes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0, // Increase button text size
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(false); // Return false when "No" is pressed.
              },
              child: Container(
                padding: EdgeInsets.all(10.0), // Add padding
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                      30.0), // Rounded corners for buttons
                  border: Border.all(color: Colors.red),
                  color: Colors.orange[900], // Border
                ),
                child: Text(
                  'No',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0, // Increase button text size
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      // Proceed to the payment page here.
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice = 0;
    double totalWeight = 0;

    for (int index = 0; index < widget.dataList.length; index++) {
      double price = widget.dataList[index]['Price']?.toDouble() ?? 0.0;
      int quantity = widget.dataList[index]['Quantity'] ?? 0;
      totalPrice += (price * quantity);

      double weight = widget.dataList[index]['Weight']?.toDouble() ?? 0.0;
      totalWeight += (weight * quantity);
    }
    updateTotalWeightInDatabase(totalWeight);

    return WillPopScope(
      onWillPop: () async {
        // Navigate back to the previous page when the back button is pressed
        Navigator.of(context).pop();
        return false; // Return false to prevent the default back behavior
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          toolbarHeight: 100,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20.0), // Adjust the radius as needed
              bottomRight: Radius.circular(20.0), // Adjust the radius as needed
            ),
          ),
          backgroundColor: Colors.blueGrey[900],
          title: Text(
            'Shopping List:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: <Widget>[
            // Wrap the Delete IconButton in a circular container
            Padding(
              padding: EdgeInsets.all(8.0), // Adjust the padding as needed
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (_isDeleting) {
                      _selectedIndices.sort();
                      for (int i = _selectedIndices.length - 1; i >= 0; i--) {
                        int index = _selectedIndices[i];
                        widget.dataList.removeAt(index);
                      }
                      _isDeleting = false;
                      _selectedIndices.clear();
                    } else {
                      _isDeleting = true;
                    }
                  });
                },
                child: Container(
                  width: 50, // Adjust the width of the circular button
                  height: 50, // Adjust the height of the circular button
                  decoration: BoxDecoration(
                    color: Colors.orange[900], // Change the color as needed
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      _isDeleting ? Icons.delete : Icons.delete_outline,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            // Wrap the Create IconButton in a circular container
            Padding(
              padding: EdgeInsets.all(8.0), // Adjust the padding as needed
              child: InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return ManualBarcodeEntryDialog(
                          dataStore: widget.dataStore);
                    },
                  );
                },
                child: Container(
                  width: 50, // Adjust the width of the circular button
                  height: 50, // Adjust the height of the circular button
                  decoration: BoxDecoration(
                    color: Colors.orange[900], // Change the color as needed
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.create,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            // Wrap the QR Code Scanner IconButton in a circular container
            Padding(
              padding: EdgeInsets.all(8.0), // Adjust the padding as needed
              child: InkWell(
                onTap: () async {
                  // Your QR code scanning logic here
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
                      widget.dataStore.updateQuantity(existingIndex, 1);
                      _showDataPage(widget.dataStore.dataList);
                    } else {
                      _plistCollection.doc(barcode).get().then((snapshot) {
                        if (snapshot.exists) {
                          Map<String, dynamic> data =
                              snapshot.data() as Map<String, dynamic>;
                          data['Quantity'] = 1;
                          data['DocumentID'] = barcode;
                          widget.dataStore.addData(data);
                          _showDataPage(widget.dataStore.dataList);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Document not found'),
                            ),
                          );
                        }
                      }).catchError((error) {
                        print('Error fetching document: $error');
                      });
                    }
                  }
                },
                child: Container(
                  width: 50, // Adjust the width of the circular button
                  height: 50, // Adjust the height of the circular button
                  decoration: BoxDecoration(
                    color: Colors.orange[900], // Change the color as needed
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.qr_code_scanner,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                children: <Widget>[
                  for (int index = 0; index < widget.dataList.length; index++)
                    DataRow(
                      data: widget.dataList[index],
                      index: index,
                      dataStore: widget.dataStore,
                      onUpdate: () {
                        setState(() {});
                      },
                      isDimmed: _selectedIndices.contains(index),
                      isSelected: _selectedIndices.contains(index),
                      onTap: () {
                        setState(() {
                          if (_isDeleting) {
                            if (_selectedIndices.contains(index)) {
                              _selectedIndices.remove(index);
                            } else {
                              _selectedIndices.add(index);
                            }
                          }
                        });
                      },
                    ),
                ],
              ),
            ),
            Container(
              // margin: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              height: 60,
              decoration: BoxDecoration(
                color: Colors.blueGrey[900], // Change the background color
                borderRadius: BorderRadius.circular(0.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ' Items: ${widget.dataList.length}   Total: ₹ ${totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Change the text color
                    ),
                  ),
                  SizedBox(height: 2),
                  Transform.scale(
                    scale: 1.5, // Adjust the scale factor to increase the size
                    child: IconButton(
                      onPressed: () {
                        _showConfirmationDialog();
                      },
                      icon: Container(
                        width: 50, // Adjust the width of the circular button
                        height: 50, // Adjust the height of the circular button
                        decoration: BoxDecoration(
                          color:
                              Colors.orange[900], // Change the color as needed
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 24, // Adjust the size as needed
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DataRow extends StatefulWidget {
  final Map<String, dynamic> data;
  final int index;
  final Function onUpdate;
  final DataStore dataStore;
  final bool isDimmed;
  final bool isSelected;
  final Function()? onTap;

  DataRow({
    required this.data,
    required this.index,
    required this.onUpdate,
    required this.dataStore,
    this.isDimmed = false,
    this.isSelected = false,
    this.onTap,
  });

  @override
  _DataRowState createState() => _DataRowState();
}

class _DataRowState extends State<DataRow> {
  int _quantity = 1;

  @override
  void initState() {
    _quantity = widget.data['Quantity'];
    super.initState();
  }

  void _updateQuantity(int value) {
    setState(() {
      _quantity += value;
      _quantity = _quantity.clamp(1, 999);
    });
    widget.dataStore.updateQuantity(widget.index, value);
    widget.onUpdate();
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice = widget.data['Price'] * _quantity.toDouble();
    double totalWeight = widget.data['Weight'] * _quantity.toDouble();

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 2, horizontal: 2),
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.indigo[900]!),
          borderRadius: BorderRadius.circular(10.0),
          color: widget.isDimmed ? Colors.red[100] : Colors.grey[50],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.data['Name'],
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[900]),
                ),
                Row(
                  children: [
                    InkWell(
                      onTap: () => _updateQuantity(-1),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white),
                          color: Colors.blueGrey[700],
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.remove,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '$_quantity',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => _updateQuantity(1),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white),
                          color: Colors.blueGrey[700],
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '(Weight: ${totalWeight.toStringAsFixed(2)}g) ',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                Text(
                  '(Price: ₹${totalPrice.toStringAsFixed(2)})',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blueGrey[900],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
