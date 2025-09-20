import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:excel/excel.dart';
import 'dart:typed_data';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String xlsxData = '';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse(
        'https://drive.google.com/uc?export=download&id=1aU6DnSrI863K0xgxU2hz-Gd5uZZ1JkVr'));

    if (response.statusCode == 200) {
      final Uint8List bytes = response.bodyBytes;
      final excel = Excel.decodeBytes(bytes);

      final StringBuffer dataBuffer = StringBuffer();

      for (var table in excel.tables.keys) {
        for (var row in excel.tables[table]!.rows) {
          final rowValues = row.map((cell) => cell?.value).toList();
          dataBuffer.write(rowValues.join('\t')); // Concatenate cell values
          dataBuffer.write('\n');
        }
      }

      setState(() {
        xlsxData = dataBuffer.toString();
      });
    } else {
      setState(() {
        xlsxData = 'Failed to fetch XLSX data';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('XLSX Display'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(xlsxData),
        ),
      ),
    );
  }
}
