// main.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Firestore Search App')),
        body: SearchScreen(),
      ),
    );
  }
}

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _docIdController = TextEditingController();
  String _searchedDocId = '';
  CollectionReference _plistCollection =
      FirebaseFirestore.instance.collection('PList');
  List<Map<String, dynamic>> _searchResults = [];

  void _showDataPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DisplayDataPage(dataList: _searchResults),
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
                    _searchResults.add(data); // Add the data to the list
                    _showDataPage();
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

  DisplayDataPage({required this.dataList});

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
  final Function onUpdate;

  DataRow({required this.data, required this.onUpdate});

  @override
  _DataRowState createState() => _DataRowState();
}

class _DataRowState extends State<DataRow> {
  int _quantity = 1;

  void _updateQuantity(int value) {
    setState(() {
      _quantity += value;
      _quantity = _quantity.clamp(1, 999); // Limit quantity between 1 and 999
    });
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
