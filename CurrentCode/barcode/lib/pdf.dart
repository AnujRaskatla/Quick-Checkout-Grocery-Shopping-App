import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PDFGenerator {
  static Future<void> generatePDF(
      List<Map<String, dynamic>> dataList, String phoneNumber) async {
    print('Generating PDF...');
    final pdf = pw.Document();
    final headers = [
      'Name',
      'Price',
      'Barcode',
      'Weight',
      'Quantity',
      'Total Price'
    ];

    // Create a Page
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              // Create a table with headers
              pw.Table(
                border: pw.TableBorder.all(
                  color: PdfColors.black,
                  width: 0.5, // Set the border width as needed
                ),
                children: [
                  pw.TableRow(
                    children: headers.map((header) {
                      print('Adding header: $header');
                      return pw.Text(header);
                    }).toList(),
                    decoration: pw.BoxDecoration(color: PdfColors.grey300),
                  ),
                  // Add rows of data
                  for (var data in dataList)
                    pw.TableRow(
                      children: [
                        pw.Text(data['Name'].toString()),
                        pw.Text(data['Price']?.toStringAsFixed(2) ?? ''),
                        pw.Text(data['Barcode_Number'].toString()),
                        pw.Text(data['Weight']?.toStringAsFixed(2) ?? ''),
                        pw.Text(data['Quantity']?.toString() ?? ''),
                        pw.Text(
                          (data['Price'] * (data['Quantity'] ?? 0))
                              .toStringAsFixed(2),
                        ),
                      ],
                    ),
                ],
              ),

              // Create a bottom row with total price
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                      'Total Price: ₹${calculateTotalPrice(dataList).toStringAsFixed(2)}'),
                ],
              ),
            ],
          );
        },
      ),
    );

    // Save the PDF to a file
    print('Saving PDF to a file...');
    final output = await getTemporaryDirectory();
    final fileName = '$phoneNumber.pdf'; // Use phone number as the filename
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
    print('PDF saved to file: ${file.path}');

    // Upload the PDF to Firebase Storage
    try {
      print('Uploading PDF to Firebase Storage...');
      final Reference storageReference =
          FirebaseStorage.instance.ref().child('pdfs/$fileName');
      final UploadTask uploadTask = storageReference.putFile(file);

      await uploadTask.whenComplete(() {
        print('PDF uploaded to Firebase Storage: $fileName');
      });
    } catch (e) {
      print('Failed to upload PDF to Firebase Storage: $e');
    }
  }

  static double calculateTotalPrice(List<Map<String, dynamic>> dataList) {
    double totalPrice = 0;
    for (var data in dataList) {
      final price = data['Price'] ?? 0;
      final quantity = data['Quantity'] ?? 0;
      totalPrice += price * quantity;
    }
    print('Total Price calculated: $totalPrice');
    return totalPrice;
  }
}
