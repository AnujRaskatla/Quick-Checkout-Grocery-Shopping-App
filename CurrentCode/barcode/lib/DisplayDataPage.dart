// main.dart
// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors_in_immutables, prefer_const_constructors, library_private_types_in_public_api, prefer_final_fields, avoid_print, deprecated_member_use, file_names

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'GlobalData.dart';
import 'ScanBarcodePage.dart';
import 'PaymentPage.dart';

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
          title: Text('Confirm'),
          content: Text('Do you want to end your shopping?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(true); // Return true when "Yes" is pressed.
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(false); // Return false when "No" is pressed.
              },
              child: Text('No'),
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
          builder: (context) => PaymentPage(
            phoneNumber: GlobalData.phoneNumber,
          ),
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Display Data'),
        actions: <Widget>[
          IconButton(
            icon: Icon(_isDeleting ? Icons.delete : Icons.delete_outline),
            onPressed: () {
              setState(() {
                if (_isDeleting) {
                  // Delete selected rows
                  _selectedIndices.sort(); // Sort indices in ascending order
                  for (int i = _selectedIndices.length - 1; i >= 0; i--) {
                    int index = _selectedIndices[i];
                    widget.dataList.removeAt(index);
                  }
                  _isDeleting = false;
                  _selectedIndices.clear();
                } else {
                  // Enable delete mode
                  _isDeleting = true;
                }
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.create), // Manually enter barcode icon
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return ManualBarcodeEntryDialog(dataStore: widget.dataStore);
                },
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.qr_code_scanner),
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
            margin: EdgeInsets.symmetric(vertical: 2, horizontal: 8.0),
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
                      '  Items: ${widget.dataList.length}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    //Text(
                    //   '(${totalWeight.toStringAsFixed(2)})',
                    // style: TextStyle(
                    //   fontSize: 10,
                    //   ),
                    // ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment
                            .end, // Center the button vertically
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              _showConfirmationDialog();
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Color(0xFFFF725E),
                              onPrimary: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text('Proceed'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          '  Total Price: ₹${totalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
        margin: EdgeInsets.symmetric(vertical: 2),
        padding: EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: BorderRadius.circular(12.0),
          color: widget.isDimmed ? Colors.grey : Colors.white,
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
                  '(₹) $totalPrice ',
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
                            onPressed: () => _updateQuantity(-1),
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
                        Text(' $_quantity ', style: TextStyle(fontSize: 18)),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: ElevatedButton(
                            onPressed: () => _updateQuantity(1),
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
      ),
    );
  }
}
