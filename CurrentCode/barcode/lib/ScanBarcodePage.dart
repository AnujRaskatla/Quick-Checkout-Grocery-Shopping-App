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
          backgroundColor: Colors.black,
          title: const Text(
            'Select an Option:',
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
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
                    // Check if the scanned barcode already exists in the list
                    ScannedItemsModel scannedItemsModel =
                        Provider.of<ScannedItemsModel>(context, listen: false);

                    if (scannedItemsModel.scannedItems.contains(barcode)) {
                      // If the barcode exists, increment its quantity
                      scannedItemsModel.incrementQuantity(barcode);
                    } else {
                      // If the barcode is new, add it to the list
                      scannedItemsModel.addScannedItem(barcode);
                    }
                  }
                },
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
                child: const Text('Enter Barcode Manually'),
              ),
            ],
          ),
        ));
  }
}
