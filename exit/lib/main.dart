import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
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
  DatabaseReference databaseReference = FirebaseDatabase.instance.reference();
  double? totalWeight;

  @override
  void initState() {
    super.initState();
    _fetchTotalWeight();
  }

  Future<void> _fetchTotalWeight() async {
    final reference =
        databaseReference.child('cartNumbers/${widget.scannedValue}');

    try {
      final event = await reference.once();
      final dataSnapshot = event.snapshot;
      if (dataSnapshot.value != null) {
        final data = dataSnapshot.value as Map<dynamic, dynamic>;
        if (data.containsKey('totalWeight')) {
          setState(() {
            totalWeight = data['totalWeight'] as double; // Change to double
          });
        }
      } else {
        setState(() {
          totalWeight = null; // Data not found
        });
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
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
          ],
        ),
      ),
    );
  }
}
