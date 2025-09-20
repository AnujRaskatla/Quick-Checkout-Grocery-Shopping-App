// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors_in_immutables, prefer_const_declarations, avoid_print, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'GlobalData.dart';
import 'dart:convert';

class ThankYouPage extends StatelessWidget {
  ThankYouPage();

  Future<void> sendPDFLinkByEmail(String fileName) async {
    final storage = FirebaseStorage.instance;
    final pdfRef = storage.ref().child('invoices/$fileName');
    final pdfUrl = await pdfRef.getDownloadURL();

    // Compose the email message with the PDF link
    String message = 'Here is the PDF file for payment: $pdfUrl';

    // Use the MailerSend API to send the email
    final apiURL = 'https://api.mailersend.com/v1/email';

    final apiKey =
        'mlsn.d6b91eee9c469639b659a1f42aa60559dbce8f45c8025f1420a0eed40d0d90c5'; // Replace with your MailerSend API key
    final fromEmail = 'pawanpk0987@gmail.com';
    final toEmail = '${GlobalData.userEmail}';
    print('User: ${GlobalData.userEmail}');

    final emailData = {
      "from": {"email": fromEmail},
      "to": [
        {"email": toEmail}
      ],
      "subject": "Your subject",
      "text": message,
      "html": "<p>Your HTML content</p>",
    };

    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $apiKey",
    };

    final response = await http.post(
      Uri.parse(apiURL),
      headers: headers,
      body: json.encode(emailData),
    );

    if (response.statusCode == 200) {
      print('Email sent successfully');
    } else {
      print('Failed to send email: ${response.statusCode}');
      print(response.body);
    }

    // Check if the URL can be launched
    if (await canLaunch(pdfUrl)) {
      // Launch the URL in the default browser
      await launch(pdfUrl);
    } else {
      print('Could not launch $pdfUrl');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Delete $cartNumber and totalweight fields from Firebase Realtime Database
    final DatabaseReference databaseReference =
        FirebaseDatabase.instance.reference();
    databaseReference.child("cartNumbers/").update({
      "${GlobalData.cartNumber}": null,
      "totalWeight": null,
    });
    databaseReference.child("Status/").update({
      "${GlobalData.cartNumber}": null,
    });
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.60,
              child: Image.asset('assets/tq.jpg'),
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: () async {
                await sendPDFLinkByEmail('${GlobalData.userEmail}-invoice.pdf');
              },
              child: RichText(
                text: const TextSpan(
                  text: 'Here is the link to the PDF with your shopping bill: ',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Send Email',
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
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}
