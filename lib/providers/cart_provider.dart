import '../models/product.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// providers/cart_provider.dart

class CartProvider with ChangeNotifier {
  final Map<String, Product> _cartItems = {};

  Map<String, Product> get items => _cartItems;

  void addToCart(Product product) {
    _cartItems[product.id] = product;
    notifyListeners();
  }

  void removeFromCart(String id) {
    _cartItems.remove(id);
    notifyListeners();
  }

  double get total => _cartItems.values.fold(0, (sum, item) => sum + item.price);

  Future<void> placeOrder(String userId) async {
    final timestamp = DateTime.now().toIso8601String();
    await FirebaseFirestore.instance.collection('orders').add({
      'userId': userId,
      'timestamp': timestamp,
      'items': _cartItems.values.map((e) => {
        'name': e.name,
        'price': e.price,
        'image': e.image,
      }).toList(),
      'total': total,
    });
    _cartItems.clear();
    notifyListeners();
  }
}
