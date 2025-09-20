import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ScannedItemsModel(),
      child: const MyApp(),
    ),
  );
}

class ScannedItemsModel extends ChangeNotifier {
  List<String> scannedItems = [];

  void addScannedItem(String barcode) {
    scannedItems.add(barcode);
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barcode App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomePage(),
        '/scan': (context) => const ScanBarcodePage(),
        '/list': (context) => const ViewListPage(),
      },
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome Anuj',
              style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/scan'),
              child: const Text('Scan Barcode'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/list'),
              child: const Text('View List'),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class ScanBarcodePage extends StatelessWidget {
  const ScanBarcodePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            String barcode = await FlutterBarcodeScanner.scanBarcode(
              '#FF0000',
              'Cancel',
              true,
              ScanMode.BARCODE,
            );

            if (barcode.isNotEmpty) {
              Provider.of<ScannedItemsModel>(context, listen: false)
                  .addScannedItem(barcode);
            }
          },
          child: const Text('Start Barcode Scan'),
        ),
      ),
    );
  }
}

class ViewListPage extends StatefulWidget {
  const ViewListPage({super.key});

  @override
  ViewListPageState createState() => ViewListPageState();
}

class ViewListPageState extends State<ViewListPage>
    with AutomaticKeepAliveClientMixin {
  List<String> scannedItems = [];

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final scannedItemsModel = Provider.of<ScannedItemsModel>(context);
    final List<String> scannedItems = scannedItemsModel.scannedItems;
    final String? barcode =
        ModalRoute.of(context)!.settings.arguments as String?;

    if (barcode != null) {
      print('Scanned Barcode: $barcode');
      scannedItems.add(barcode);
      print('Scanned Items: $scannedItems');
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: DataTable(
          columns: const <DataColumn>[
            DataColumn(label: Text('S.no')),
            DataColumn(label: Text('Barcode Number')),
            DataColumn(label: Text('Weight')),
          ],
          rows: List<DataRow>.generate(
            scannedItems.length,
            (index) => DataRow(cells: <DataCell>[
              DataCell(Text((index + 1).toString())),
              DataCell(Text(scannedItems[index])),
              const DataCell(Text('')),
            ]),
          ),
        ),
      ),
    );
  }
}
