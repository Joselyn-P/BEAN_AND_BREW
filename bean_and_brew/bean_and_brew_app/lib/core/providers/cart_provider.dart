import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../services/storage_service.dart';

class CartProvider extends ChangeNotifier {
  int _itemCount = 0;
  int get itemCount => _itemCount;

  Future<void> loadCart() async {
    try {
      final token = await StorageService.getToken();
      if (token == null) return;

      final res = await http.get(
        Uri.parse(ApiConstants.cart),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        _itemCount = data['item_count'] ?? 0;
        notifyListeners();
      }
    } catch (e) {
      _itemCount = 0;
      notifyListeners();
    }
  }

  void setCount(int count) {
    _itemCount = count;
    notifyListeners();
  }

  void increment() {
    _itemCount++;
    notifyListeners();
  }

  void reset() {
    _itemCount = 0;
    notifyListeners();
  }
}