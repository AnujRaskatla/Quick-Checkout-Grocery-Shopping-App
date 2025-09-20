import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'DisplayDataPage.dart';
import 'IntermediatePage.dart';
import 'GlobalData.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      double storedInitialPrice = prefs.getDouble('initialPrice') ?? 0;
      if (storedInitialPrice != 0) {
        initialPrice = storedInitialPrice;
      } else {
        initialPrice = currentPrice;
        prefs.setDouble('initialPrice', initialPrice);
      }

      double difference = currentPrice - initialPrice;
      print('Difference: $difference');
      if (difference > 0) {
        //  updateTotalPriceInPaise(currentPrice);
        paymentprice = (difference).toInt();
        print('Refund will be Processed in payment page');
        print('Initial Price1: $initialPrice');
        print('Current Price1: $currentPrice');

        print('paymentprice1: $paymentprice');
        initiateRazorpayPayment(context);
      } else {
        // If difference is negative

        print('Initial Price2: $initialPrice');
        print('Current Price2: $currentPrice');
        paymentprice = currentPrice.toInt();
        print('paymentprice2: $paymentprice');
        initiateRazorpayPayment(context);
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Go Back',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
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
                    color: Colors.indigo[900],
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Redirecting to Payment Gateway...',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
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
