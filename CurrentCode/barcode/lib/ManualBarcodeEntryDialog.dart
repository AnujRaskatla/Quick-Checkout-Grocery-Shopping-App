// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// for CSV parsing
import 'ScannedItemsModel.dart';

class ManualBarcodeEntryDialog extends StatefulWidget {
  const ManualBarcodeEntryDialog({super.key});

  @override
  ManualBarcodeEntryDialogState createState() =>
      ManualBarcodeEntryDialogState();
}

class ManualBarcodeEntryDialogState extends State<ManualBarcodeEntryDialog> {
  final TextEditingController _barcodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter Barcode Manually'),
      content: TextField(
        controller: _barcodeController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'Barcode'),
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            String enteredBarcode = _barcodeController.text;
            if (enteredBarcode.isNotEmpty) {
              ScannedItemsModel scannedItemsModel =
                  Provider.of<ScannedItemsModel>(context, listen: false);

              if (scannedItemsModel.scannedItems.contains(enteredBarcode)) {
                // If the barcode exists, increment its quantity
                scannedItemsModel.incrementQuantity(enteredBarcode);
              } else {
                // If the barcode is new, add it to the list
                scannedItemsModel.addScannedItem(enteredBarcode);
              }

              Navigator.pop(context);
            }
          },
          child: const Text('Add'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
