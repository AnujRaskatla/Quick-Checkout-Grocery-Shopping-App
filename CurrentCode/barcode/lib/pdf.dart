// ignore_for_file: prefer_const_constructors, prefer_const_declarations, deprecated_member_use, avoid_print

import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pdf/widgets.dart';
import 'package:weigh/GlobalData.dart';

class PDFGenerator {
  static Future<void> generatePDF(List<Map<String, dynamic>> dataList) async {
    final pdf = pw.Document();

    // Define custom styles for the document
    final TextStyle headerStyle = pw.TextStyle(fontWeight: pw.FontWeight.bold);
    final TextStyle cellStyle = pw.TextStyle(fontSize: 10);
    final double totalAmountFontSize = 12;

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) {
          return <pw.Widget>[
            pw.Header(
              child: pw.Text('Invoice:', style: pw.TextStyle(fontSize: 30)),
              level: 0,
            ),
            pw.Padding(padding: pw.EdgeInsets.only(bottom: 10)),
            pw.Table.fromTextArray(
              headers: ['S.no', 'Description', 'Price', 'Qty.', 'Total'],
              headerStyle: headerStyle,
              data: <List<String>>[
                for (var i = 0; i < dataList.length; i++)
                  [
                    (i + 1).toString(), // S.no
                    dataList[i]['Name'].toString(),
                    dataList[i]['Price'].toStringAsFixed(2),
                    dataList[i]['Quantity'].toString(),
                    (dataList[i]['Price'] * dataList[i]['Quantity'])
                        .toStringAsFixed(2)
                  ],
              ],
              cellStyle: cellStyle,
            ),
            pw.Padding(padding: pw.EdgeInsets.only(bottom: 10)),
            pw.Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  '  Items: ${dataList.length.toString()}',
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
                pw.Text(
                  'Total Amount: ${calculateTotalPrice(dataList).toStringAsFixed(2)}/-',
                  style: pw.TextStyle(fontSize: totalAmountFontSize),
                ),
              ],
            ),
          ];
        },
      ),
    );

    // Save the PDF to a file
    final output = await getTemporaryDirectory();
    final fileName = '${GlobalData.userEmail}-invoice.pdf';
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    // Upload the PDF to Firebase Storage
    try {
      final Reference storageReference =
          FirebaseStorage.instance.ref().child('invoices/$fileName');
      final UploadTask uploadTask = storageReference.putFile(file);

      await uploadTask.whenComplete(() {
        print('Invoice PDF uploaded to Firebase Storage: $fileName');
      });
    } catch (e) {
      print('Failed to upload Invoice PDF to Firebase Storage: $e');
    }
  }

  static double calculateTotalPrice(List<Map<String, dynamic>> dataList) {
    double totalPrice = 0;
    for (var data in dataList) {
      final price = data['Price'] ?? 0;
      final quantity = data['Quantity'] ?? 0;
      totalPrice += price * quantity;
    }
    return totalPrice;
  }
}
