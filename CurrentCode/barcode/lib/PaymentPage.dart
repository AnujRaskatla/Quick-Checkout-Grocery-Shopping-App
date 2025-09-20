// ignore_for_file: prefer_const_constructors, avoid_print, file_names, use_key_in_widget_constructors, deprecated_member_use, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
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

  // Upload XLSX file to Firebase Storage
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

  // Upload PDF file to Firebase Storage
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

  // Send PDF via WhatsApp
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

  Future<void> copyPDFLinkToClipboard(String pdfFileName) async {
    final storage = FirebaseStorage.instance;

    try {
      final pdfRef = storage.ref().child(pdfFileName);
      final pdfUrl = await pdfRef.getDownloadURL();

      String message = 'Here is the PDF file for payment: $pdfUrl';

      final ClipboardData data = ClipboardData(text: message);
      await Clipboard.setData(data);

      print('PDF link copied to clipboard.');
    } catch (e) {
      print('Error retrieving PDF download URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32.0),
            child: Column(
              children: [
                Icon(
                  Icons.payment,
                  size: 64.0,
                  color: Colors.black,
                ),
                SizedBox(height: 16.0),
                Text(
                  'Select a Payment Option',
                  style: TextStyle(
                    fontSize: 24.0,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                buildPaymentButton('UPI', Colors.grey[300]!, Icons.payment,
                    () async {
                  await processPayment();
                }),
                SizedBox(height: 16),
                buildPaymentButton(
                    'Debit Card', Colors.grey[300]!, Icons.payment, () async {
                  await processPayment();
                }),
                SizedBox(height: 16),
                buildPaymentButton(
                    'Net Banking', Colors.grey[300]!, Icons.payment, () async {
                  await processPayment();
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPaymentButton(
      String label, Color color, IconData icon, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: color,
          padding: const EdgeInsets.all(16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.black,
            ),
            SizedBox(width: 8.0),
            Text(
              label,
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Process payment logic
  Future<void> processPayment() async {
    File xlsxFile = File('${Directory.systemTemp.path}/scanned_items.xlsx');
    await uploadXLSXToFirebase(xlsxFile);

    await PdfGenerator.createPDF(
        scannedItems, barcodeToInfoMap, scannedItemsModel, phoneNumber);
    File pdfFile = File('${Directory.systemTemp.path}/$phoneNumber.pdf');
    await uploadPDFToFirebase(pdfFile);
    // Send PDF to WhatsApp
    //await sendPDFViaWhatsApp('$phoneNumber.pdf');

    // Copy PDF link to Clipboard
    await copyPDFLinkToClipboard('$phoneNumber.pdf');
  }
}
