import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import '../models/cart_item.dart';
import '../models/order_item.dart';

class OrderProvider extends ChangeNotifier {
  List<OrderItem> _orders = [];
  final _supabase = Supabase.instance.client;

  OrderProvider() {
    _loadOrders();
  }

  List<OrderItem> get orders => [..._orders];

  Future<void> _loadOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? ordersJson = prefs.getString('user_orders');
      if (ordersJson != null) {
        final List<dynamic> decoded = json.decode(ordersJson);
        _orders = decoded.map((item) => OrderItem.fromJson(item)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading orders: $e');
    }
  }

  Future<void> addOrder(
    List<CartItem> cartProducts, 
    double total, {
    String serviceDate = '', 
    String serviceTime = '',
    String userEmail = '',
    String userName = '',
  }) async {
    final newOrder = OrderItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: total,
      products: cartProducts,
      dateTime: DateTime.now(),
      serviceDate: serviceDate,
      serviceTime: serviceTime,
    );
    
    _orders.insert(0, newOrder);
    notifyListeners();
    
    // Guardado Local (Persistencia inmediata)
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = json.encode(_orders.map((o) => o.toJson()).toList());
      await prefs.setString('user_orders', encoded);
      debugPrint('Pedido guardado localmente con éxito');
    } catch (e) {
      debugPrint('Error al guardar pedido localmente: $e');
    }

    // Guardado en Supabase (Persistencia remota)
    try {
      final List<Map<String, dynamic>> orderItems = cartProducts.map((item) => {
        'nombre': item.title,
        'cantidad': item.quantity,
        'precio': item.price,
        'imagen': item.imageUrl,
        'descripcion': 'Pedido de $userName ($userEmail)',
        'categoria': 'Pedido',
        'servicio': 'Agendado para $serviceDate a las $serviceTime',
      }).toList();

      // Intentamos insertar en la tabla 'pedidos' si existe
      // O en su defecto, intentamos mapear a la estructura sugerida
      for (var item in orderItems) {
        await _supabase.from('pedidos').insert(item).select();
      }
      debugPrint('Pedido sincronizado con Supabase');
    } catch (e) {
      debugPrint('Error al sincronizar con Supabase (posiblemente la tabla no existe): $e');
      // Si falla Supabase, el pedido sigue guardado localmente
    }
  }
}
