// ignore_for_file: file_names, use_build_context_synchronously

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
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: const Text(
          'Select an Option:',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                      Provider.of<ScannedItemsModel>(context, listen: false);

                  if (scannedItemsModel.scannedItems.contains(barcode)) {
                    scannedItemsModel.incrementQuantity(barcode);
                  } else {
                    scannedItemsModel.addScannedItem(barcode);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.grey[300],
              ),
              child: const Text('Start Barcode Scan'),
            ),
            const SizedBox(height: 20),
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
                foregroundColor: Colors.black,
                backgroundColor: Colors.grey[300],
              ),
              child: const Text('Enter Barcode Manually'),
            ),
          ],
        ),
      ),
    );
  }
}
