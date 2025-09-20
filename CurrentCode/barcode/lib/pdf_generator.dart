// ignore_for_file: deprecated_member_use, avoid_print

import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'ScannedItemsModel.dart';

class PdfGenerator {
  static Future<void> createPDF(
    List<String> scannedItems,
    Map<String, List<String>> barcodeToInfoMap,
    ScannedItemsModel scannedItemsModel,
    String phoneNumber,
  ) async {
    final pdf = pw.Document();

    final data = <List<String>>[
      <String>['Qty', 'S.no', 'Name', 'Barcode Number', 'Price', 'Weight'],
    ];

    double totalPrice = 0.0;
    double totalWeight = 0.0;

    for (int index = 0; index < scannedItems.length; index++) {
      final scannedItem = scannedItems[index];
      final info = barcodeToInfoMap[scannedItem] ?? ['N/A', '0.0', '0.0'];
      final quantity = scannedItemsModel.getQuantity(scannedItem);
      final initialPrice = double.tryParse(info[1]) ?? 0.0;
      final initialWeight = double.tryParse(info[2]) ?? 0.0;
      final updatedPrice = initialPrice * quantity;
      final updatedWeight = initialWeight * quantity;

      data.add([
        quantity.toString(),
        (index + 1).toString(),
        info.length > 0 ? info[0] : 'N/A',
        scannedItem,
        updatedPrice.toStringAsFixed(2),
        updatedWeight.toStringAsFixed(2),
      ]);

      totalPrice += updatedPrice;
      totalWeight += updatedWeight;
    }

    // Add total row
    data.add([
      'Total:',
      '',
      '',
      '',
      totalPrice.toStringAsFixed(2),
      totalWeight.toStringAsFixed(2),
    ]);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('Shopping List:'),
              ),
              pw.Table.fromTextArray(
                context: context,
                data: data,
              ),
            ],
          );
        },
      ),
    );

    // Save the PDF to a file with the phone number as the name
    final file = File('${Directory.systemTemp.path}/$phoneNumber.pdf');
    await file.writeAsBytes(await pdf.save());
    print('PDF file saved at: ${file.path}');
  }
}
