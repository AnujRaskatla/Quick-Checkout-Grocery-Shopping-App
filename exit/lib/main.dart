import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the first Firebase project (replace with your first project config)
  await Firebase.initializeApp(
    name: 'first_project',
    options: FirebaseOptions(
      appId: '1:667053041442:web:09d8f82f7985fa214b277b',
      apiKey: 'AIzaSyDPTOp4u6Ge3MhD4smBhrceIRmbpjWkMnU',
      projectId: 'esp32-e3373',
      messagingSenderId: '667053041442',
      databaseURL: 'https://esp32-e3373-default-rtdb.firebaseio.com',
    ),
  );

  // Initialize the second Firebase project (replace with your second project config)
  await Firebase.initializeApp(
    name: 'second_project',
    options: FirebaseOptions(
      apiKey: 'AIzaSyAVVvU_wXUnlABsrQLGo2pfm8mQmaMvskw',
      appId: '1:877289501258:android:3b92b99f4f07930a92acb3',
      messagingSenderId: '877289501258',
      projectId: 'mainweigh',
      databaseURL: 'https://mainweigh-default-rtdb.firebaseio.com',
    ),
  );

  runApp(QRScannerApp());
}

class QRScannerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FirstPage(),
    );
  }
}

class FirstPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Scanner'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QRScannerPage(),
                  ),
                );

                if (result != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ResultPage(scannedValue: result),
                    ),
                  );
                }
              },
              child: Text('Scan QR'),
            ),
          ],
        ),
      ),
    );
  }
}

class QRScannerPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late QRViewController controller;
  bool isScanning = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Scanner'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            if (isScanning) {
              controller.dispose();
            }
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;

    controller.scannedDataStream.listen((scanData) {
      if (isScanning) {
        setState(() {
          isScanning = false;
          // Pass the scanned value back to the FirstPage
          Navigator.pop(context, scanData.code);
        });
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class ResultPage extends StatefulWidget {
  final String scannedValue;

  ResultPage({required this.scannedValue});

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  late DatabaseReference firstProjectReference;
  late DatabaseReference secondProjectReference;
  double? totalWeight;
  double? weightValue;
  String comparisonResult = ''; // To store the comparison result text
  Color resultColor = Colors.black; // To store the text color

  @override
  void initState() {
    super.initState();

    // Initialize references to both projects' databases
    firstProjectReference = FirebaseDatabase(
      app: Firebase.app('first_project'), // Use the first Firebase app
    ).reference();

    secondProjectReference = FirebaseDatabase(
      app: Firebase.app('second_project'), // Use the second Firebase app
    ).reference();

    // Fetch data for both "totalWeight" and "Weight"
    _fetchTotalWeight();
    _fetchWeight();
    // Add a listener to update weightValue when it changes in the database
    _listenToWeightChanges();
  }

  Future<void> _fetchTotalWeight() async {
    final reference =
        secondProjectReference.child('cartNumbers/${widget.scannedValue}');

    try {
      final event = await reference.once();
      final dataSnapshot = event.snapshot;
      if (dataSnapshot.value != null) {
        final data = dataSnapshot.value as Map<dynamic, dynamic>;
        final totalWeightValue = data['totalWeight'];
        if (totalWeightValue is double || totalWeightValue is int) {
          setState(() {
            totalWeight = totalWeightValue.toDouble();
            // Compare the values and set the comparison result
            _compareValues();
          });
        } else {
          setState(() {
            totalWeight = null;
            // Compare the values and set the comparison result
            _compareValues();
          });
        }
      }
    } catch (error) {
      print('Error fetching data from the second project: $error');
    }
  }

  Future<void> _fetchWeight() async {
    final weightReference =
        firstProjectReference.child('Counter Number 2/Weight');

    try {
      final weightEvent = await weightReference.once();
      final weightDataSnapshot = weightEvent.snapshot;
      if (weightDataSnapshot.value != null) {
        setState(() {
          weightValue = weightDataSnapshot.value as double;
          // Compare the values and set the comparison result
          _compareValues();
        });
      }
    } catch (error) {
      print('Error fetching "Weight" data from the first project: $error');
    }
  }

  // Compare the values and set the comparison result
  void _compareValues() {
    if (totalWeight != null && weightValue != null) {
      final difference = (totalWeight! - weightValue!).abs();
      if (difference <= 1) {
        setState(() {
          comparisonResult = 'Weights Matched';
          resultColor = Colors.green;
        });
      } else {
        setState(() {
          comparisonResult = 'Weights not Matched';
          resultColor = Colors.red;
        });
      }
    }
  }

  void _listenToWeightChanges() {
    final weightReference =
        firstProjectReference.child('Counter Number 2/Weight');

    weightReference.onValue.listen((event) {
      final weightDataSnapshot = event.snapshot;
      if (weightDataSnapshot.value != null) {
        setState(() {
          weightValue = weightDataSnapshot.value as double;
          // Compare the values and set the comparison result
          _compareValues();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Result Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Scanned Number: ${widget.scannedValue}',
                style: TextStyle(fontSize: 18)),
            if (totalWeight != null)
              Text('Total Weight: $totalWeight',
                  style: TextStyle(fontSize: 18)),
            if (totalWeight == null)
              Text('Total Weight not found',
                  style: TextStyle(fontSize: 18, color: Colors.red)),

            // Display "Weight" if available
            if (weightValue != null)
              Text('Weight: $weightValue', style: TextStyle(fontSize: 18)),

            // Display the comparison result with the specified text color
            Text(
              comparisonResult,
              style: TextStyle(fontSize: 18, color: resultColor),
            ),
          ],
        ),
      ),
    );
  }
}
