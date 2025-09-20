// ignore_for_file: file_names

import 'package:flutter/material.dart';

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
