import 'package:flutter/material.dart';

class DisplayDataPage extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> data;

  DisplayDataPage({required this.docId, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Display Data')),
      body: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Column(
          children: <Widget>[
            Text('Document ID: $docId'),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(12.0), // Rounded corners
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.start, // Align to the start
                    children: [
                      Expanded(
                        child: Text(
                          '${data['Name']}',
                          style: TextStyle(
                            fontSize: 18, // Adjust the font size as needed
                            fontWeight: FontWeight.bold, // Bold
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '${data['Price']}',
                          style: TextStyle(
                            fontSize: 18, // Adjust the font size as needed
                            fontWeight: FontWeight.bold, // Bold
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.start, // Align to the start
                    children: [
                      Expanded(
                        child: Text('${data['Barcode_Number']}'),
                      ),
                      Expanded(
                        child: Text('${data['Weight']}'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
