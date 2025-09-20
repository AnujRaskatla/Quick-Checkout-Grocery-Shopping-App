// ignore_for_file: file_names, prefer_is_empty, avoid_print, prefer_const_constructors, use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:csv/csv.dart';
import 'package:http/http.dart' as http;
import 'pdf_generator.dart';
import 'ScannedItemsModel.dart';
import 'PaymentPage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'GlobalData.dart';

class ViewListPage extends StatefulWidget {
  final ScannedItemsModel scannedItemsModel; // Add this line
  final String phoneNumber;
  const ViewListPage({
    Key? key,
    required this.scannedItemsModel,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  ViewListPageState createState() => ViewListPageState();
}

class ViewListPageState extends State<ViewListPage>
    with AutomaticKeepAliveClientMixin {
  Map<String, List<String>> barcodeToInfoMap = {};
  String csvData = '';
  double receivedWeight = 0.0; // Added received weight
  double fetchedWeight = 0.0;

  late DatabaseReference _databaseReference;

  @override
  void initState() {
    super.initState();
    _databaseReference = FirebaseDatabase.instance.reference();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse(
        'https://drive.google.com/uc?export=download&id=1NIC2S560GZRIwNhe5SxTT49iVJD1ffsK'));
    List<List<dynamic>> csvTable =
        const CsvToListConverter().convert(response.body);

    barcodeToInfoMap = {};
    for (var row in csvTable) {
      String barcode = row[1].toString();
      List<String> info = [
        row[0].toString(),
        row[2].toString(),
        row[3].toString()
      ];
      barcodeToInfoMap[barcode] = info;
    }

    setState(() {});
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

  DataRow _buildDataRow(
      ScannedItemsModel scannedItemsModel, String scannedItem, int index) {
    List<String> info = barcodeToInfoMap[scannedItem] ?? ['N/A', '0.0', '0.0'];
    int quantity = scannedItemsModel.getQuantity(scannedItem);
    double initialPrice = double.tryParse(info[1]) ?? 0.0;
    double initialWeight = double.tryParse(info[2]) ?? 0.0;
    double updatedPrice = initialPrice * quantity;
    double updatedWeight = initialWeight * quantity;

    return DataRow(cells: <DataCell>[
      DataCell(Row(
        children: [
          IconButton(
            onPressed: () {
              scannedItemsModel.incrementQuantity(scannedItem);
            },
            icon: const Icon(Icons.add),
          ),
          Text(quantity.toString()),
          IconButton(
            onPressed: () {
              scannedItemsModel.decrementQuantity(scannedItem);
            },
            icon: const Icon(Icons.remove),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                scannedItemsModel.scannedItems.removeAt(index);
              });
            },
            icon: const Icon(Icons.delete),
          ),
        ],
      )),
      DataCell(Text((index + 1).toString())),
      DataCell(Text(info.length > 0 ? info[0] : 'N/A')),
      DataCell(Text(scannedItem)),
      DataCell(Text(updatedPrice.toStringAsFixed(2))),
      DataCell(Text(updatedWeight.toStringAsFixed(2))),
    ]);
  }

  DataRow _buildTotalRow(
      ScannedItemsModel scannedItemsModel, double totalWeight) {
    double totalPrice = 0.0;
    totalWeight = 0.0; // Remove the redeclaration of totalWeight

    for (String scannedItem in scannedItemsModel.scannedItems) {
      List<String> info =
          barcodeToInfoMap[scannedItem] ?? ['N/A', '0.0', '0.0'];
      double price = double.tryParse(info[1]) ?? 0.0;
      double weight = double.tryParse(info[2]) ?? 0.0;
      int quantity = scannedItemsModel.getQuantity(scannedItem);

      totalPrice += price * quantity;
      totalWeight += weight * quantity;
    }
    // Update total weight in the database
    updateTotalWeightInDatabase(totalWeight);
    return DataRow(
      cells: <DataCell>[
        const DataCell(Text('Total:')),
        const DataCell(Text('')),
        const DataCell(Text('')),
        const DataCell(Text('')),
        DataCell(Text(totalPrice.toStringAsFixed(2))),
        DataCell(Text(totalWeight.toStringAsFixed(2))),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final scannedItemsModel = Provider.of<ScannedItemsModel>(context);
    final List<String> scannedItems = scannedItemsModel.scannedItems;

    double totalWeight = 0.0;
    for (String scannedItem in scannedItems) {
      List<String> info =
          barcodeToInfoMap[scannedItem] ?? ['N/A', '0.0', '0.0'];
      double weight = double.tryParse(info[2]) ?? 0.0;
      int quantity = scannedItemsModel.getQuantity(scannedItem);
      totalWeight += weight * quantity;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: const Text(
          'Scanned Products:',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                headingTextStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
                dataTextStyle:
                    const TextStyle(fontSize: 14, color: Colors.black87),
                horizontalMargin: 20,
                columnSpacing: 20.0,
                columns: const <DataColumn>[
                  DataColumn(label: Text('Qty.')),
                  DataColumn(label: Text('S.no')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Barcode Number')),
                  DataColumn(label: Text('Price')),
                  DataColumn(label: Text('Weight')),
                ],
                rows: [
                  for (int index = 0; index < scannedItems.length; index++)
                    _buildDataRow(
                        scannedItemsModel, scannedItems[index], index),
                  _buildTotalRow(scannedItemsModel, totalWeight),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: ElevatedButton(
              onPressed: () async {
                await PdfGenerator.createPDF(scannedItems, barcodeToInfoMap,
                    scannedItemsModel, GlobalData.phoneNumber);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentPage(
                      scannedItems: scannedItems,
                      barcodeToInfoMap: barcodeToInfoMap,
                      scannedItemsModel: scannedItemsModel,
                      phoneNumber: GlobalData.phoneNumber,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.grey[300],
                onPrimary: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Text('Done Shopping'),
            ),
          ),
        ],
      ),
    );
  }
}
