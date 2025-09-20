import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:provider/provider.dart';
import 'package:csv/csv.dart'; // for CSV parsing
import 'package:http/http.dart' as http;

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
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text(
            'Select an Option:',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  String barcode = await FlutterBarcodeScanner.scanBarcode(
                    '#FF0000',
                    'Cancel',
                    true,
                    ScanMode.BARCODE,
                  );

                  if (barcode.isNotEmpty) {
                    // Check if the scanned barcode already exists in the list
                    ScannedItemsModel scannedItemsModel =
                        Provider.of<ScannedItemsModel>(context, listen: false);

                    if (scannedItemsModel.scannedItems.contains(barcode)) {
                      // If the barcode exists, increment its quantity
                      scannedItemsModel.incrementQuantity(barcode);
                    } else {
                      // If the barcode is new, add it to the list
                      scannedItemsModel.addScannedItem(barcode);
                    }
                  }
                },
                child: const Text('Start Barcode Scan'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const ManualBarcodeEntryDialog();
                    },
                  );

                  Navigator.pushNamed(context, '/list');
                },
                child: const Text('Enter Barcode Manually'),
              ),
            ],
          ),
        ));
  }
}

class ManualBarcodeEntryDialog extends StatefulWidget {
  const ManualBarcodeEntryDialog({super.key});

  @override
  ManualBarcodeEntryDialogState createState() =>
      ManualBarcodeEntryDialogState();
}

class ManualBarcodeEntryDialogState extends State<ManualBarcodeEntryDialog> {
  final TextEditingController _barcodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter Barcode Manually'),
      content: TextField(
        controller: _barcodeController,
        decoration: const InputDecoration(labelText: 'Barcode'),
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            String enteredBarcode = _barcodeController.text;
            if (enteredBarcode.isNotEmpty) {
              ScannedItemsModel scannedItemsModel =
                  Provider.of<ScannedItemsModel>(context, listen: false);

              if (scannedItemsModel.scannedItems.contains(enteredBarcode)) {
                // If the barcode exists, increment its quantity
                scannedItemsModel.incrementQuantity(enteredBarcode);
              } else {
                // If the barcode is new, add it to the list
                scannedItemsModel.addScannedItem(enteredBarcode);
              }

              Navigator.pop(context);
            }
          },
          child: const Text('Add'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
      ],
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
  String csvData = '';
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse(
        'https://drive.google.com/uc?export=download&id=1NIC2S560GZRIwNhe5SxTT49iVJD1ffsK'));
    List<List<dynamic>> csvTable =
        const CsvToListConverter().convert(response.body);

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

  DataRow _buildDataRow(
      ScannedItemsModel scannedItemsModel, String scannedItem, int index) {
    List<String> info = barcodeToInfoMap[scannedItem] ?? ['N/A', '0.0', '0.0'];
    int quantity = scannedItemsModel.getQuantity(scannedItem);
    double initialPrice = double.tryParse(info[1]) ?? 0.0;
    double initialWeight = double.tryParse(info[2]) ?? 0.0;
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
          IconButton(
            onPressed: () {
              setState(() {
                scannedItemsModel.scannedItems.removeAt(index);
              });
            },
            icon: const Icon(Icons.delete),
          ),
        ],
      )),
      DataCell(Text((index + 1).toString())),
      DataCell(Text(info.length > 0 ? info[0] : 'N/A')),
      DataCell(Text(scannedItem)),
      DataCell(Text(updatedPrice.toStringAsFixed(2))),
      DataCell(Text(updatedWeight.toStringAsFixed(2))),
    ]);
  }

  DataRow _buildTotalRow(ScannedItemsModel scannedItemsModel) {
    double totalPrice = 0.0;
    double totalWeight = 0.0;

    for (String scannedItem in scannedItemsModel.scannedItems) {
      List<String> info =
          barcodeToInfoMap[scannedItem] ?? ['N/A', '0.0', '0.0'];
      double price = double.tryParse(info[1]) ?? 0.0;
      double weight = double.tryParse(info[2]) ?? 0.0;
      int quantity = scannedItemsModel.getQuantity(scannedItem);

      totalPrice += price * quantity;
      totalWeight += weight * quantity;
    }

    return DataRow(
      cells: <DataCell>[
        const DataCell(Text('Total:')),
        const DataCell(Text('')),
        const DataCell(Text('')),
        const DataCell(Text('')),
        DataCell(Text(totalPrice.toStringAsFixed(2))),
        DataCell(Text(totalWeight.toStringAsFixed(2))),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final scannedItemsModel = Provider.of<ScannedItemsModel>(context);
    final List<String> scannedItems = scannedItemsModel.scannedItems;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Scanned Products:',
          style: TextStyle(color: Colors.white),
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
                horizontalMargin: 20,
                columnSpacing: 20.0,
                columns: const <DataColumn>[
                  DataColumn(label: Text('Qty.')),
                  DataColumn(label: Text('S.no')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Barcode Number')),
                  DataColumn(label: Text('Price')),
                  DataColumn(label: Text('Weight')),
                ],
                rows: [
                  for (int index = 0; index < scannedItems.length; index++)
                    _buildDataRow(
                        scannedItemsModel, scannedItems[index], index),
                  _buildTotalRow(scannedItemsModel),
                ],
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
                child: const Icon(Icons.payment),
              ),
            ),
          )
        ],
      ),
    );
  }
}
