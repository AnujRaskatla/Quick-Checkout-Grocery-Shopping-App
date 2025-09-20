import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CSV Reader',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Hi',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CSVReaderPage()),
                );
              },
              child: const Text('Read'),
            ),
          ],
        ),
      ),
    );
  }
}

class CSVReaderPage extends StatefulWidget {
  const CSVReaderPage({super.key});

  @override
  CSVReaderPageState createState() => CSVReaderPageState();
}

class CSVReaderPageState extends State<CSVReaderPage> {
  List<List<dynamic>> data = [];

  Future<void> loadCSV() async {
    final String rawCSV = await rootBundle.loadString('assets/data.csv');
    List<List<dynamic>> csvTable = const CsvToListConverter().convert(rawCSV);
    setState(() {
      data = csvTable;
    });
  }

  @override
  void initState() {
    super.initState();
    loadCSV();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CSV Reader'),
      ),
      body: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: data.isNotEmpty
                ? List<DataColumn>.generate(
                    data[0].length,
                    (index) => DataColumn(
                      label: Text(data[0][index].toString()),
                    ),
                  )
                : [],
            rows: List<DataRow>.generate(
              data.length - 1,
              (rowIndex) => DataRow(
                cells: List<DataCell>.generate(
                  data[rowIndex + 1].length,
                  (cellIndex) => DataCell(
                    Text(data[rowIndex + 1][cellIndex].toString()),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
