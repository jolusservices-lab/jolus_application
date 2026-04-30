import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../services/database_service.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};
  final DatabaseService _dbService = DatabaseService();
  String? _userId;

  Map<String, CartItem> get items => {..._items};

  int get itemCount {
    var total = 0;
    _items.forEach((key, cartItem) {
      total += cartItem.quantity;
    });
    return total;
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  void updateUserId(String? userId) {
    _userId = userId;
    if (_userId != null) {
      _syncWithSupabase();
    }
  }

  Future<void> _syncWithSupabase() async {
    if (_userId == null || _userId!.isEmpty) return;
    await _dbService.syncCart(_userId!, _items.values.toList());
  }

  void addItem(String productId, String title, double price, String imageUrl) {
    if (_items.containsKey(productId)) {
      _items.update(
        productId,
        (existingItem) => CartItem(
          id: existingItem.id,
          title: existingItem.title,
          price: existingItem.price,
          imageUrl: existingItem.imageUrl,
          quantity: existingItem.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        productId,
        () => CartItem(
          id: productId,
          title: title,
          price: price,
          imageUrl: imageUrl,
        ),
      );
    }
    _syncWithSupabase();
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    _syncWithSupabase();
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) return;
    if (_items[productId]!.quantity > 1) {
      _items.update(
        productId,
        (existingItem) => CartItem(
          id: existingItem.id,
          title: existingItem.title,
          price: existingItem.price,
          imageUrl: existingItem.imageUrl,
          quantity: existingItem.quantity - 1,
        ),
      );
    } else {
      _items.remove(productId);
    }
    _syncWithSupabase();
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _syncWithSupabase();
    notifyListeners();
  }
}
