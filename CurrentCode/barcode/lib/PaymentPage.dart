// ignore_for_file: avoid_print, file_names, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'pdf_generator.dart';
import 'ScannedItemsModel.dart';

class PaymentPage extends StatelessWidget {
  final List<String> scannedItems;
  final Map<String, List<String>> barcodeToInfoMap;
  final ScannedItemsModel scannedItemsModel;
  const PaymentPage({
    required this.scannedItems,
    required this.barcodeToInfoMap,
    required this.scannedItemsModel,
  });

  Future<void> uploadXLSXToFirebase(File file) async {
    try {
      if (file.existsSync()) {
        final storage = FirebaseStorage.instance;
        final storageRef = storage.ref().child('scanned_items.xlsx');
        await storageRef.putFile(file);
        print('XLSX file uploaded to Firebase Storage.');
      } else {
        print('XLSX file does not exist at ${file.path}.');
      }
    } catch (e) {
      print('Error uploading XLSX file to Firebase Storage: $e');
    }
  }

  Future<void> uploadPDFToFirebase(File pdfFile) async {
    try {
      if (pdfFile.existsSync()) {
        final storage = FirebaseStorage.instance;
        final storageRef = storage.ref().child('scanned_items.pdf');
        await storageRef.putFile(pdfFile);
        print('PDF file uploaded to Firebase Storage.');
      } else {
        print('PDF file does not exist at ${pdfFile.path}.');
      }
    } catch (e) {
      print('Error uploading PDF file to Firebase Storage: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Select Payment Method',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment:
              CrossAxisAlignment.stretch, // Align buttons to full width
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, // Change the button color
                  padding: const EdgeInsets.all(16.0),
                ),
                onPressed: () async {
                  File xlsxFile =
                      File('${Directory.systemTemp.path}/scanned_items.xlsx');
                  await uploadXLSXToFirebase(xlsxFile);
                  // Implement GPay payment logic here
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.payment), // Add an icon
                    SizedBox(width: 8.0), // Add spacing
                    Text(
                      'UPI',
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Change the button color
                  padding: const EdgeInsets.all(16.0),
                ),
                onPressed: () async {
                  File xlsxFile =
                      File('${Directory.systemTemp.path}/scanned_items.xlsx');
                  await uploadXLSXToFirebase(xlsxFile);
                  // Implement PhonePe payment logic here
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.payment), // Add an icon
                    SizedBox(width: 8.0), // Add spacing
                    Text(
                      'Debit Card',
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Change the button color
                  padding: const EdgeInsets.all(16.0),
                ),
                onPressed: () async {
                  File xlsxFile =
                      File('${Directory.systemTemp.path}/scanned_items.xlsx');
                  await uploadXLSXToFirebase(xlsxFile);
                  await PdfGenerator.createPDF(
                      scannedItems, barcodeToInfoMap, scannedItemsModel);
                  File pdfFile =
                      File('${Directory.systemTemp.path}/scanned_items.pdf');
                  await uploadPDFToFirebase(pdfFile);
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.payment), // Add an icon
                    SizedBox(width: 8.0), // Add spacing
                    Text(
                      'Net Banking',
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
