import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'ESP32 LED Control',
      home: LedControlPage(),
    );
  }
}

class LedControlPage extends StatelessWidget {
  final String esp32IP = '192.168.1.102';

  const LedControlPage({super.key}); // Replace with your ESP32's IP address

  Future<void> _sendCommand(String command) async {
    final response = await http.get(Uri.http(esp32IP, '/$command'));
    if (response.statusCode == 200) {
      print('Command sent: $command');
    } else {
      print('Failed to send command: $command');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LED Control')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _sendCommand('LED=ON'),
              child: const Text('Turn On LED'),
            ),
            ElevatedButton(
              onPressed: () => _sendCommand('LED=OFF'),
              child: const Text('Turn Off LED'),
            ),
          ],
        ),
      ),
    );
  }
}
