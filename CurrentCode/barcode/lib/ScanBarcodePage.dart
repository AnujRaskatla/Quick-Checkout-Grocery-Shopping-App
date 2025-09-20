// ignore_for_file: file_names, prefer_const_constructors, use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:provider/provider.dart';
import 'ScannedItemsModel.dart';
import 'ManualBarcodeEntryDialog.dart';

class ScanBarcodePage extends StatelessWidget {
  const ScanBarcodePage({super.key});

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
                      ScannedItemsModel scannedItemsModel =
                          Provider.of<ScannedItemsModel>(context,
                              listen: false);

                      if (scannedItemsModel.scannedItems.contains(barcode)) {
                        scannedItemsModel.incrementQuantity(barcode);
                      } else {
                        scannedItemsModel.addScannedItem(barcode);
                      }
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
                        return const ManualBarcodeEntryDialog();
                      },
                    );

                    Navigator.pushNamed(context, '/list');
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
