// ignore_for_file: file_names, prefer_const_literals_to_create_immutables, prefer_const_constructors, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.qr_code_scanner,
                  size: 36,
                  color: Colors.indigo[900],
                ),
                SizedBox(width: 10),
                Text(
                  'Enter Barcode Number',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo[900],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            TextField(
              controller: _barcodeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Type Barcode Number here',
                labelStyle: TextStyle(
                  color: Colors.indigo[900], // Label text color
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blue, // Border color when not focused
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    String enteredBarcode = _barcodeController.text;
                    if (enteredBarcode.isNotEmpty) {
                      ScannedItemsModel scannedItemsModel =
                          Provider.of<ScannedItemsModel>(context,
                              listen: false);

                      if (scannedItemsModel.scannedItems
                          .contains(enteredBarcode)) {
                        // If the barcode exists, increment its quantity
                        scannedItemsModel.incrementQuantity(enteredBarcode);
                      } else {
                        // If the barcode is new, add it to the list
                        scannedItemsModel.addScannedItem(enteredBarcode);
                      }

                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFFFF725E),
                    onPrimary: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                  child: const Text('Add'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFFFF725E),
                    onPrimary: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
