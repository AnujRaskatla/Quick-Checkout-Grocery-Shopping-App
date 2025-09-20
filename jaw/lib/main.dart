import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'ESP32 Weight App',
      home: WeightPage(),
    );
  }
}

class WeightPage extends StatefulWidget {
  const WeightPage({super.key});

  @override
  WeightPageState createState() => WeightPageState();
}

class WeightPageState extends State<WeightPage> {
  String weight = 'N/A';

  void fetchWeight() async {
    try {
      final response =
          await http.get(Uri.parse('http://192.168.50.35/getWeight'));
      if (response.statusCode == 200) {
        setState(() {
          weight = response.body;
        });
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
      appBar: AppBar(title: const Text('ESP32 Weight App')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Weight: $weight kg', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: fetchWeight,
              child: const Text('Fetch Weight'),
            ),
          ],
        ),
      ),
    );
  }
}
