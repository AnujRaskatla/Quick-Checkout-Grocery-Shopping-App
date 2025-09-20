// ignore_for_file: avoid_print, prefer_const_constructors, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, file_names, library_private_types_in_public_api, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'DisplayDataPage.dart';
import 'IntermediatePage.dart';
import 'GlobalData.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'RefundPage.dart';

class PaymentPage extends StatefulWidget {
  final List<Map<String, dynamic>> dataList;
  final DataStore dataStore;
  PaymentPage({required this.dataStore, required this.dataList});

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late Razorpay _razorpay;
  bool firstTime = true;
  int paymentprice = 0;
  double initialPrice = 0;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    print('GlobalWeight in paymentpage: ${GlobalData.totalPriceInPaise}');
    print(
        'GlobalWeight in paymentpage in INT: ${(GlobalData.totalPriceInPaise * 100).toInt()}');

    double currentPrice = GlobalData.totalPriceInPaise;

    SharedPreferences.getInstance().then((prefs) {
      //   double storedInitialPrice = prefs.getDouble('initialPrice') ?? 0;
      //  if (storedInitialPrice != 0) {
      //    initialPrice = storedInitialPrice;
      //  } else {
      //    initialPrice = currentPrice;
      //    prefs.setDouble('initialPrice', initialPrice);
      //  }
      print('Current Price (bd): $currentPrice');
      print('Initial Price (bd): $initialPrice');
      print('Meter (bd): ${GlobalData.meter}');
      currentPrice = currentPrice - GlobalData.meter;
      double difference = currentPrice - initialPrice;
      GlobalData.meter = difference + GlobalData.meter;
      print('Meter (ad): ${GlobalData.meter}');
      print('Difference: $difference');
      if (difference > 0) {
        //  updateTotalPriceInPaise(currentPrice);
        paymentprice = (difference).toInt();

        print('Initial Price (st): $initialPrice');
        print('Current Price (st): $currentPrice');

        print('paymentprice (st): $paymentprice');
        initiateRazorpayPayment(context);
      } else {
        // If difference is negative
        if (difference == 0) {
          print('Initial Price (ft): $initialPrice');
          print('Current Price (ft): $currentPrice');
          paymentprice = currentPrice.toInt();
          print('paymentprice (ft): $paymentprice');
          initiateRazorpayPayment(context);
        } else {
          print('Refund will be Processed in payment page');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RefundPage(
                dataList: widget.dataList,
                dataStore: widget.dataStore,
              ), // Replace with your RefundPage widget
            ),
          );
        }
      }
    });
  }

  // void updateTotalPriceInPaise(double price) {
  //   print('double price: $price');
  //  GlobalData.totalPriceInPaise = price;
//
  //  paymentprice = (GlobalData.totalPriceInPaise * 100).toInt();
  //  print('updateTotalPriceInPaise: $paymentprice');
//  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print('Payment Successful: ${response.paymentId}');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IntermediatePage(
          dataList: widget.dataList,
          dataStore: widget.dataStore,
        ),
      ),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print('Payment Error: ${response.message}');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('External Wallet Payment: ${response.walletName}');
  }

  Future<void> initiateRazorpayPayment(BuildContext context) async {
    print('inside initiateRazorpayPayment: $paymentprice');
    final options = {
      'key': 'rzp_test_PULsb8Zi0vfFig',
      'amount': '$paymentprice',
      'name': 'ZuppCart',
      'description': 'Payment for your order',
      'prefill': {
        'contact': '',
        'email': "${GlobalData.userEmail}",
      },
      'external': {
        'wallets': ['paytm'],
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print('Error initiating Razorpay payment: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const Text(
                    'Go Back',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.60,
            child: Image.asset('assets/pg.jpg'),
          ),
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Redirecting to Payment Gateway...',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
