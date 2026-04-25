import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/cart_item.dart';
import '../models/order_item.dart';

class OrderProvider extends ChangeNotifier {
  List<OrderItem> _orders = [];

  OrderProvider() {
    _loadOrders();
  }

  List<OrderItem> get orders => [..._orders];

  Future<void> _loadOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final String? ordersJson = prefs.getString('user_orders');
    if (ordersJson != null) {
      final List<dynamic> decoded = json.decode(ordersJson);
      _orders = decoded.map((item) => OrderItem.fromJson(item)).toList();
      notifyListeners();
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final newOrder = OrderItem(
      id: DateTime.now().toString(),
      amount: total,
      products: cartProducts,
      dateTime: DateTime.now(),
    );
    _orders.insert(0, newOrder);
    
    final prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(_orders.map((o) => o.toJson()).toList());
    await prefs.setString('user_orders', encoded);
    
    notifyListeners();
  }
}
