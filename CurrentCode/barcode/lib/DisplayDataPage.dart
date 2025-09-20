// main.dart
// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors_in_immutables, prefer_const_constructors, library_private_types_in_public_api, prefer_final_fields, avoid_print, deprecated_member_use

import 'package:flutter/material.dart';

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
                  'Items: ${widget.dataList.length}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '(${totalWeight.toStringAsFixed(2)})',
                  style: TextStyle(
                    fontSize: 10,
                  ),
                ),
                Text(
                  'Total Price: ₹${totalPrice.toStringAsFixed(2)}',
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
