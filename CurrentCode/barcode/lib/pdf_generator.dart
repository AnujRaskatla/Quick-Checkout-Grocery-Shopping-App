// ignore_for_file: deprecated_member_use, avoid_print

import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'ScannedItemsModel.dart';

class PdfGenerator {
  static Future<void> createPDF(
    List<String> scannedItems,
    Map<String, List<String>> barcodeToInfoMap,
    ScannedItemsModel scannedItemsModel, // Pass the model as a parameter
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('Scanned Products'),
              ),
              pw.Table.fromTextArray(
                context: context,
                data: <List<String>>[
                  <String>[
                    'Qty',
                    'S.no',
                    'Name',
                    'Barcode Number',
                    'Price',
                    'Weight'
                  ],
                  for (int index = 0; index < scannedItems.length; index++)
                    [
                      scannedItemsModel
                          .getQuantity(scannedItems[index])
                          .toString(),
                      (index + 1).toString(),
                      barcodeToInfoMap[scannedItems[index]]?[0] ?? 'N/A',
                      scannedItems[index],
                      (double.tryParse(barcodeToInfoMap[scannedItems[index]]
                                      ?[1] ??
                                  '0.0')! *
                              scannedItemsModel
                                  .getQuantity(scannedItems[index]))
                          .toStringAsFixed(2),
                      (double.tryParse(barcodeToInfoMap[scannedItems[index]]
                                      ?[2] ??
                                  '0.0')! *
                              scannedItemsModel
                                  .getQuantity(scannedItems[index]))
                          .toStringAsFixed(2),
                    ],
                ],
              ),
            ],
          );
        },
      ),
    );

    // Save the PDF to a file
    final file = File('${Directory.systemTemp.path}/scanned_items.pdf');
    await file.writeAsBytes(await pdf.save());
    print('PDF file saved at: ${file.path}');
  }
}
