import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/order_model.dart';
import '../services/database_service.dart';

class OrderProvider extends ChangeNotifier {
  List<OrderModel> _orders = [];
  final DatabaseService _dbService = DatabaseService();
  bool _isLoading = false;

  List<OrderModel> get orders => [..._orders];
  bool get isLoading => _isLoading;

  Future<void> fetchOrders(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final List<Map<String, dynamic>> data = await _dbService.getUserOrders(userId);
      _orders = data.map((json) => OrderModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error al cargar pedidos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> placeOrder({
    required String userId,
    required double total,
    required List<CartItem> items,
    String? direccion,
    String? metodoPago,
    String? telefono,
    String? comentario,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final String? pedidoId = await _dbService.createOrder(
        userId: userId,
        total: total,
        items: items,
        direccion: direccion,
        metodoPago: metodoPago,
        telefono: telefono,
        comentario: comentario,
      );

      if (pedidoId != null) {
        // Recargar pedidos para tener la lista actualizada
        await fetchOrders(userId);
        return pedidoId;
      }
      return null;
    } catch (e) {
      debugPrint('Error al realizar el pedido: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
