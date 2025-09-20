// main.dart
// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors_in_immutables, prefer_const_constructors, library_private_types_in_public_api, prefer_final_fields, avoid_print, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final dataStore = DataStore();
  runApp(MyApp(dataStore: dataStore));
}

class MyApp extends StatelessWidget {
  final DataStore dataStore;

  MyApp({required this.dataStore});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Firestore Search App')),
        body: SearchScreen(dataStore: dataStore),
      ),
    );
  }
}

class SearchScreen extends StatefulWidget {
  final DataStore dataStore;

  SearchScreen({required this.dataStore});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _docIdController = TextEditingController();
  String _searchedDocId = '';
  CollectionReference _plistCollection =
      FirebaseFirestore.instance.collection('PList');

  void _showDataPage(List<Map<String, dynamic>> dataList) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            DisplayDataPage(dataList: dataList, dataStore: widget.dataStore),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: _docIdController,
            decoration: InputDecoration(labelText: 'Enter Document ID'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _searchedDocId = _docIdController.text;
              });
              if (_searchedDocId.isNotEmpty) {
                _plistCollection.doc(_searchedDocId).get().then((snapshot) {
                  if (snapshot.exists) {
                    Map<String, dynamic> data =
                        snapshot.data() as Map<String, dynamic>;
                    data['Quantity'] = 1; // Initial quantity
                    widget.dataStore.addData(data); // Add the data to DataStore
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
            },
            child: Text('Search'),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

class DisplayDataPage extends StatefulWidget {
  final List<Map<String, dynamic>> dataList;
  final DataStore dataStore;

  DisplayDataPage({required this.dataList, required this.dataStore});

  @override
  _DisplayDataPageState createState() => _DisplayDataPageState();
}

class _DisplayDataPageState extends State<DisplayDataPage> {
  @override
  Widget build(BuildContext context) {
    double totalPrice = 0;

    // Calculate the total price based on your data
    for (int index = 0; index < widget.dataList.length; index++) {
      double price = widget.dataList[index]['Price']?.toDouble() ?? 0.0;
      int quantity = widget.dataList[index]['Quantity'] ?? 0;
      totalPrice += (price * quantity);
    }

    return Scaffold(
      appBar: AppBar(title: Text('Display Data')),
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
                  ),
              ],
            ),
          ),
          // New row at the bottom
          Container(
            margin: EdgeInsets.symmetric(vertical: 2),
            padding: EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Items: ${widget.dataList.length}', // Total number of rows
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Total Price: ₹${totalPrice.toStringAsFixed(2)}', // Total price
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
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

  DataRow(
      {required this.data,
      required this.index,
      required this.onUpdate,
      required this.dataStore});

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
      _quantity = _quantity.clamp(1, 999); // Limit quantity between 1 and 999
    });
    widget.dataStore.updateQuantity(widget.index, value);
    widget.onUpdate();
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice = widget.data['Price'] * _quantity.toDouble();
    double totalWeight =
        widget.data['Weight'] * _quantity.toDouble(); // Cast to double

    return Container(
      margin: EdgeInsets.symmetric(vertical: 2),
      padding: EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.circular(12.0), // Rounded corners
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
                    '($totalWeight) ',
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 20, // Adjust the button size as needed
                        height: 20, // Adjust the button size as needed
                        decoration: BoxDecoration(
                          color: Colors.red, // Red color for "-"
                          borderRadius: BorderRadius.circular(
                              15.0), // Half of the width/height for a circle
                        ),
                        child: ElevatedButton(
                          onPressed: () => _updateQuantity(-1),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  15.0), // Match the container's border radius
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '-',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color:
                                    Colors.black, // White color for the symbol
                              ),
                            ),
                          ),
                        ),
                      ),
                      Text(' $_quantity ', style: TextStyle(fontSize: 18)),
                      Container(
                        width: 20, // Adjust the button size as needed
                        height: 20, // Adjust the button size as needed
                        decoration: BoxDecoration(
                          color: Colors.green, // Green color for "+"
                          borderRadius: BorderRadius.circular(
                              15.0), // Half of the width/height for a circle
                        ),
                        child: ElevatedButton(
                          onPressed: () => _updateQuantity(1),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  15.0), // Match the container's border radius
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '+',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color:
                                    Colors.black, // White color for the symbol
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
