// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors_in_immutables, avoid_print, prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';

class ThankYouPage extends StatelessWidget {
  final String pdfFileName;
  final String phoneNumber;

  ThankYouPage({required this.pdfFileName, required this.phoneNumber});

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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.check_circle,
                  size: 48,
                  color: Colors.green,
                ),
                SizedBox(width: 10),
                Text(
                  'Thank You',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            InkWell(
              onTap: () async {
                await copyPDFLinkToClipboard('$phoneNumber.pdf');
              },
              child: RichText(
                text: TextSpan(
                  text: 'Here is the link to the PDF with your shopping bill: ',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Copy Link',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}
