// ignore_for_file: avoid_print, file_names, use_key_in_widget_constructors, deprecated_member_use

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'pdf_generator.dart';
import 'ScannedItemsModel.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentPage extends StatelessWidget {
  final List<String> scannedItems;
  final Map<String, List<String>> barcodeToInfoMap;
  final ScannedItemsModel scannedItemsModel;
  final String phoneNumber;

  const PaymentPage({
    required this.scannedItems,
    required this.barcodeToInfoMap,
    required this.scannedItemsModel,
    required this.phoneNumber,
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
        final storageRef = storage.ref().child('$phoneNumber.pdf');
        await storageRef.putFile(pdfFile);
        print('PDF file uploaded to Firebase Storage.');
      } else {
        print('PDF file does not exist at ${pdfFile.path}.');
      }
    } catch (e) {
      print('Error uploading PDF file to Firebase Storage: $e');
    }
  }

  Future<void> sendPDFViaWhatsApp(String pdfFileName) async {
    final storage = FirebaseStorage.instance;

    try {
      final pdfRef = storage.ref().child(pdfFileName);
      final pdfUrl = await pdfRef.getDownloadURL();

      String message = 'Here is the PDF file for payment: $pdfUrl';
      String whatsappUrl =
          "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}}";

      if (await canLaunch(whatsappUrl)) {
        await launch(whatsappUrl);
      } else {
        print('Could not launch WhatsApp.');
      }
    } catch (e) {
      print('Error retrieving PDF download URL: $e');
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
                  await PdfGenerator.createPDF(scannedItems, barcodeToInfoMap,
                      scannedItemsModel, phoneNumber);
                  File pdfFile =
                      File('${Directory.systemTemp.path}/$phoneNumber.pdf');
                  await uploadPDFToFirebase(pdfFile);
                  // Send PDF to WhatsApp
                  await sendPDFViaWhatsApp('$phoneNumber.pdf');

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
                  await PdfGenerator.createPDF(scannedItems, barcodeToInfoMap,
                      scannedItemsModel, phoneNumber);
                  File pdfFile =
                      File('${Directory.systemTemp.path}/$phoneNumber.pdf');
                  await uploadPDFToFirebase(pdfFile);
                  // Send PDF to WhatsApp
                  await sendPDFViaWhatsApp('$phoneNumber.pdf');
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
                  await PdfGenerator.createPDF(scannedItems, barcodeToInfoMap,
                      scannedItemsModel, phoneNumber);
                  File pdfFile =
                      File('${Directory.systemTemp.path}/$phoneNumber.pdf');
                  await uploadPDFToFirebase(pdfFile);
                  // Send PDF to WhatsApp
                  await sendPDFViaWhatsApp('$phoneNumber.pdf');
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
