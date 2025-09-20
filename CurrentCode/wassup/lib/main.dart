import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void sendPdfViaWhatsApp() async {
  // Replace with the actual URL of your PDF file
  String pdfUrl =
      'https://drive.google.com/file/d/13jHvukJp0ukSEbFK-ADacBoTBoXRMrwv/view?usp=sharing';

  // Replace with the recipient's mobile number, including the country code (e.g., +1 for USA)
  String recipientNumber = '+918143775210';

  // Create a message that includes the PDF link
  String message = 'Hey! Check out this PDF: $pdfUrl';

  // Construct the WhatsApp URL
  String whatsappUrl =
      'https://wa.me/$recipientNumber/?text=${Uri.encodeComponent(message)}';

  // Convert the URL string to a Uri object
  Uri uri = Uri.parse(whatsappUrl);

  // Launch the URL in the browser (WhatsApp will handle the rest)
  if (await launchUrl(uri)) {
    await launchUrl(uri);
  } else {
    // Handle error
    print('Could not launch WhatsApp.');
  }
}

void main() {
  runApp(const WhatsAppPdfSender());
}

class WhatsAppPdfSender extends StatelessWidget {
  const WhatsAppPdfSender({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Send PDF via WhatsApp'),
        ),
        body: const Center(
          child: ElevatedButton(
            onPressed: sendPdfViaWhatsApp,
            child: Text('Send PDF'),
          ),
        ),
      ),
    );
  }
}
