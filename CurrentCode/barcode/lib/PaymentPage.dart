// ignore_for_file: file_names, use_key_in_widget_constructors, avoid_print, deprecated_member_use, prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart'; // Import Razorpay package
import 'pdf_generator.dart';
import 'ScannedItemsModel.dart';
import 'package:url_launcher/url_launcher.dart';
import 'IntermediatePage.dart';

class PaymentPage extends StatefulWidget {
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

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Payment was successful
    // You can implement your logic here, e.g., navigate to a success page
    print('Payment Successful: ${response.paymentId}');
    String pdfFileName = '${widget.phoneNumber}.pdf';
    // Navigate to IntermediatePage after successful payment and PDF upload
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IntermediatePage(
          pdfFileName: pdfFileName,
          phoneNumber: widget.phoneNumber,
        ),
      ),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Payment failed
    // You can implement your error handling logic here, e.g., show an error message
    print('Payment Error: ${response.message}');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Handle external wallet payments (e.g., Paytm, Google Pay)
    print('External Wallet Payment: ${response.walletName}');
  }

  Future<void> uploadPDFToFirebase(File pdfFile) async {
    try {
      if (pdfFile.existsSync()) {
        final storage = FirebaseStorage.instance;
        final storageRef = storage.ref().child('${widget.phoneNumber}.pdf');
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
          "https://wa.me/${widget.phoneNumber}?text=${Uri.encodeComponent(message)}}";

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

  Future<void> processPayment(BuildContext context) async {
    await PdfGenerator.createPDF(widget.scannedItems, widget.barcodeToInfoMap,
        widget.scannedItemsModel, widget.phoneNumber);
    File pdfFile =
        File('${Directory.systemTemp.path}/${widget.phoneNumber}.pdf');
    await uploadPDFToFirebase(pdfFile);

    // Call the method to initiate the Razorpay payment
    await initiateRazorpayPayment(context);
  }

  Future<void> initiateRazorpayPayment(BuildContext context) async {
    final options = {
      'key': 'rzp_test_PULsb8Zi0vfFig',
      'amount': 10000, // Replace with the actual amount in paise
      'name': 'Your App Name',
      'description': 'Payment for your order',
      'prefill': {
        'contact': widget.phoneNumber,
        'email': 'example@email.com',
      },
      'external': {
        'wallets': ['paytm'],
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print('Error initiating Razorpay payment: $e');
      // Handle error, e.g., show an error message
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
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
            SizedBox(height: 16.0),
            buildPaymentButton('UPI', Colors.grey[300]!, Icons.payment,
                () async {
              await processPayment(context);
            }),
            SizedBox(height: 16),
            buildPaymentButton('Debit Card', Colors.grey[300]!, Icons.payment,
                () async {
              await processPayment(context);
            }),
            SizedBox(height: 16),
            buildPaymentButton('Net Banking', Colors.grey[300]!, Icons.payment,
                () async {
              await processPayment(context);
            }),
          ],
        ),
      ),
    );
  }
}
