import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart'; // for rootBundle
import 'package:csv/csv.dart'; // for CSV parsing

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
  Map<String, int> itemQuantities = {}; // Map to store quantities

  void addScannedItem(String barcode) {
    scannedItems.add(barcode);
    itemQuantities[barcode] = 1; // Set initial quantity to 1
    notifyListeners();
  }

  int getQuantity(String barcode) {
    return itemQuantities[barcode] ?? 0;
  }

  void incrementQuantity(String barcode) {
    itemQuantities[barcode] = (itemQuantities[barcode] ?? 0) + 1;
    notifyListeners();
  }

  void decrementQuantity(String barcode) {
    if (itemQuantities[barcode] != null && itemQuantities[barcode]! > 0) {
      itemQuantities[barcode] = itemQuantities[barcode]! - 1;
      notifyListeners();
    }
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
  const ViewListPage({Key? key}) : super(key: key);

  @override
  ViewListPageState createState() => ViewListPageState();
}

class ViewListPageState extends State<ViewListPage>
    with AutomaticKeepAliveClientMixin {
  Map<String, List<String>> barcodeToInfoMap = {};

  @override
  void initState() {
    super.initState();
    loadCsvData();
  }

  Future<void> loadCsvData() async {
    String csvData = await rootBundle
        .loadString('assets/data.csv'); // Replace with your CSV file path
    List<List<dynamic>> csvTable = const CsvToListConverter().convert(csvData);

    barcodeToInfoMap = {};
    for (var row in csvTable) {
      String barcode = row[1].toString();
      List<String> info = [
        row[0].toString(),
        row[2].toString(),
        row[3].toString()
      ];
      barcodeToInfoMap[barcode] = info;
    }

    setState(() {});
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final scannedItemsModel = Provider.of<ScannedItemsModel>(context);
    final List<String> scannedItems = scannedItemsModel.scannedItems;

    double totalPrice = 0.0;
    double totalWeight = 0.0;

    for (String scannedItem in scannedItems) {
      List<String> info =
          barcodeToInfoMap[scannedItem] ?? ['N/A', 'N/A', 'N/A'];
      if (info.length > 1) {
        double price = double.tryParse(info[1]) ?? 0.0;
        double weight = double.tryParse(info[2]) ?? 0.0;
        totalPrice += price;
        totalWeight += weight;
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Scanned Products',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                headingTextStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.blue,
                ),
                dataTextStyle:
                    const TextStyle(fontSize: 14, color: Colors.black87),
                horizontalMargin: 20, // Add margin to the horizontal sides
                columnSpacing: 20.0,
                columns: const <DataColumn>[
                  DataColumn(label: Text('Qty.')), // Qty. column
                  DataColumn(label: Text('S.no')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Barcode Number')),
                  DataColumn(label: Text('Price')),
                  DataColumn(label: Text('Weight')),
                ],
                rows: List<DataRow>.generate(
                  scannedItems.length,
                  (index) {
                    String scannedItem = scannedItems[index];
                    List<String> info =
                        barcodeToInfoMap[scannedItem] ?? ['N/A', 'N/A', 'N/A'];
                    int quantity = scannedItemsModel.getQuantity(scannedItem);
// Get initial price and weight values from the info list
                    double initialPrice =
                        double.tryParse(info.length > 1 ? info[1] : '0.0') ??
                            0.0;
                    double initialWeight =
                        double.tryParse(info.length > 2 ? info[2] : '0.0') ??
                            0.0;

                    // Calculate updated price and weight based on quantity
                    double updatedPrice = initialPrice * quantity;
                    double updatedWeight = initialWeight * quantity;

                    return DataRow(cells: <DataCell>[
                      DataCell(Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              scannedItemsModel.incrementQuantity(scannedItem);
                            },
                            icon: const Icon(Icons.add),
                          ),
                          Text(quantity.toString()),
                          IconButton(
                            onPressed: () {
                              scannedItemsModel.decrementQuantity(scannedItem);
                            },
                            icon: const Icon(Icons.remove),
                          ),
                        ],
                      )),
                      DataCell(Text((index + 1).toString())),
                      DataCell(Text(info.length > 0 ? info[0] : 'N/A')),
                      DataCell(Text(scannedItem)),
                      DataCell(Text(updatedPrice
                          .toStringAsFixed(2))), // Use updated price here
                      DataCell(Text(updatedWeight
                          .toStringAsFixed(2))), // Use updated weight here
                    ]);
                  },
                )..add(
                    DataRow(cells: <DataCell>[
                      const DataCell(Text('Total')),
                      const DataCell(Text('')),
                      const DataCell(Text('')),
                      const DataCell(Text('')),
                      DataCell(Text(totalPrice.toStringAsFixed(2))),
                      DataCell(Text(totalWeight.toStringAsFixed(2))),
                    ]),
                  ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FloatingActionButton(
                onPressed: () {
                  // Add your payment logic here
                  // For example, you could navigate to a payment screen.
                  // Navigator.pushNamed(context, '/payment');
                },
                backgroundColor: Colors.blue,
                child: const Icon(Icons.payment), // Customize the button color
              ),
            ),
          )
        ],
      ),
    );
  }
}
