// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'ScannedItemsModel.dart';

class ReceivedWeightPage extends StatefulWidget {
  final double totalWeight;
  final ScannedItemsModel scannedItemsModel;

  const ReceivedWeightPage({
    Key? key,
    required this.totalWeight,
    required this.scannedItemsModel,
  }) : super(key: key);

  @override
  ReceivedWeightPageState createState() => ReceivedWeightPageState();
}

class ReceivedWeightPageState extends State<ReceivedWeightPage> {
  bool isReceivedWeightEqualToTotal = false;
  String fetchedWeight = 'N/A';

  @override
  void initState() {
    super.initState();
    fetchWeight(); // Fetch weight when the page is initialized
  }

  void fetchWeight() async {
    try {
      final response =
          await http.get(Uri.parse('http://192.168.1.102/getWeight'));
      if (response.statusCode == 200) {
        setState(() {
          fetchedWeight = response.body;
        });

        double fetchedWeightValue = double.tryParse(fetchedWeight) ?? 0;
        double totalWeightValue = widget.totalWeight.toDouble();

        if ((fetchedWeightValue - totalWeightValue).abs() <= 50) {
          setState(() {
            isReceivedWeightEqualToTotal = true;
          });
        } else {
          setState(() {
            isReceivedWeightEqualToTotal = false;
          });
        }
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Weight Check:',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16.0),
            Text(
              'Fetched Weight: $fetchedWeight ',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            if (isReceivedWeightEqualToTotal)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Weighing Scale = Total Product Weight',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                backgroundColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Make Payment',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
