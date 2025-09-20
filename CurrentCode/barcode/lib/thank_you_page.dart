// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors_in_immutables, avoid_print, prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http; // Import the HTTP package
import 'GlobalData.dart';

class ThankYouPage extends StatelessWidget {
  ThankYouPage();

  Future<void> copyPDFLinkToClipboard(String fileName) async {
    final storage = FirebaseStorage.instance;

    try {
      final pdfRef = storage.ref().child('invoices/$fileName');
      final pdfUrl = await pdfRef.getDownloadURL();

      String message = 'Here is the PDF file for payment: $pdfUrl';

      final ClipboardData data = ClipboardData(text: message);
      await Clipboard.setData(data);

      print('PDF link copied to clipboard.');

      // Make an HTTP request to your server to send the email
      final response = await http.post(
        Uri.parse(
            'http://65214e89474d2f4d4b49.appwrite.global/'), // Replace with your server's endpoint
        body: {
          'to': GlobalData.userEmail,
          'subject': 'Your Shopping Bill PDF Link',
          'html':
              'Here is the link to the PDF with your shopping bill: <a href="$pdfUrl">Download PDF</a>',
        },
      );

      if (response.statusCode == 200) {
        print('Email sent successfully.');
      } else {
        print('Failed to send email. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error retrieving PDF download URL or sending email: $e');
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
                await copyPDFLinkToClipboard(
                    '${GlobalData.userEmail}-invoice.pdf');
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
