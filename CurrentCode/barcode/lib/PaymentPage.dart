// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, avoid_print, file_names, use_key_in_widget_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart'; // Import Razorpay package
import 'IntermediatePage.dart';
import 'GlobalData.dart';

class PaymentPage extends StatefulWidget {
  final String phoneNumber;
  final int totalPriceInPaise;
  const PaymentPage(
      {required this.phoneNumber, required this.totalPriceInPaise});

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

    // Initiate Razorpay payment when the page loads
    initiateRazorpayPayment(context);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Payment was successful
    // You can implement your logic here, e.g., navigate to a success page
    print('Payment Successful: ${response.paymentId}');

    // Navigate to IntermediatePage after successful payment and PDF upload
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IntermediatePage(
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

  Future<void> initiateRazorpayPayment(BuildContext context) async {
    final options = {
      'key': 'rzp_test_PULsb8Zi0vfFig',
      'amount':
          widget.totalPriceInPaise, // Replace with the actual amount in paise
      'name': 'ZuppCart',
      'description': 'Payment for your order',
      'prefill': {
        'contact': widget.phoneNumber,
        'email': GlobalData.userName,
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
                    'Redirecting to Payment Gateway...',
                    style: TextStyle(
                      fontSize: 24.0,
                      color: Colors.indigo[900],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
