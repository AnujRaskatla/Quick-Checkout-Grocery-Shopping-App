import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:provider/provider.dart';
import 'package:csv/csv.dart'; // for CSV parsing
import 'package:http/http.dart' as http;

class LoginPage extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Hello',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Enter your Name'),
            ),
            const SizedBox(height: 10),
            const TextField(
              decoration: InputDecoration(labelText: 'Enter your Phone Number'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String enteredName = _nameController.text;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WelcomePage(userName: enteredName),
                  ),
                );
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

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
        primarySwatch: Colors.grey,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/scan': (context) => const ScanBarcodePage(),
        '/list': (context) => const ViewListPage(),
      },
    );
  }
}

class WelcomePage extends StatelessWidget {
  final String userName;

  const WelcomePage({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome $userName,',
              style: const TextStyle(
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
          iconTheme: const IconThemeData(color: Colors.white),
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
        keyboardType: TextInputType.number,
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
  double receivedWeight = 0.0; // Added received weight

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

  DataRow _buildTotalRow(
      ScannedItemsModel scannedItemsModel, double totalWeight) {
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

    double totalWeight = 0.0;
    for (String scannedItem in scannedItems) {
      List<String> info =
          barcodeToInfoMap[scannedItem] ?? ['N/A', '0.0', '0.0'];
      double weight = double.tryParse(info[2]) ?? 0.0;
      int quantity = scannedItemsModel.getQuantity(scannedItem);
      totalWeight += weight * quantity;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Scanned Products:',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
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
                  color: Colors.black,
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
                  _buildTotalRow(scannedItemsModel, totalWeight),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReceivedWeightPage(
                        totalWeight: totalWeight,
                        scannedItemsModel: scannedItemsModel,
                      ),
                    ),
                  );
                },
                child: const Text('Done Shopping'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
        print('Fetched Weight: $fetchedWeight');
        print('Total Weight: ${widget.totalWeight.toString()}');

        // Convert the fetched weight and total weight to double for comparison
        double fetchedWeightValue = double.tryParse(fetchedWeight) ?? 0;
        double totalWeightValue = widget.totalWeight.toDouble();

        // Check if the absolute difference is within 50 units
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
          'Make Payment:',
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
                    color: Colors.green, // Change color to green for success
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                // Navigate to payment screen or perform payment logic here
                // Navigator.pushNamed(context, '/payment');
              },
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
            const SizedBox(height: 40), // Add space after the button
          ],
        ),
      ),
    );
  }
}
