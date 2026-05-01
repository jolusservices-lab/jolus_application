import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/service_model.dart';
import '../models/user_model.dart';
import '../models/profile_admin_model.dart';
import '../models/payment_receipt_model.dart';
import '../models/cart_item.dart';

class DatabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // --- PRODUCTOS ---
  Future<List<ServiceModel>> getProducts() async {
    try {
      final data = await _supabase.from('productos').select('*').order('nombre');
      return (data as List).map((json) => ServiceModel.fromJson(json)).toList();
    } catch (e) {
      print('Error al obtener productos: $e');
      return [];
    }
  }

  Future<List<ServiceModel>> getProductsByService(String serviceType) async {
    try {
      final data = await _supabase.from('productos').select('*').ilike('servicio', serviceType);
      return (data as List).map((json) => ServiceModel.fromJson(json)).toList();
    } catch (e) {
      print('Error al filtrar productos por servicio: $e');
      return [];
    }
  }

  // --- USUARIOS ---
  Future<bool> checkEmailExists(String email) async {
    try {
      final response = await _supabase
          .from('usuarios')
          .select('correo')
          .eq('correo', email)
          .maybeSingle();
      return response != null;
    } catch (e) {
      return false;
    }
  }

  Future<void> syncUser(UserModel user) async {
    try {
      await _supabase.from('usuarios').upsert(user.toJson());
    } catch (e) {
      print('Error al sincronizar usuario: $e');
    }
  }

  Future<UserModel?> getUser(String userId) async {
    try {
      final data = await _supabase.from('usuarios').select().eq('user_id', userId).maybeSingle();
      if (data != null) return UserModel.fromJson(data);
    } catch (e) {
      print('Error al obtener usuario: $e');
    }
    return null;
  }

  Future<String?> uploadUserPhoto(String userId, dynamic fileBytes, String extension) async {
    try {
      final fileName = '$userId/avatar_${DateTime.now().millisecondsSinceEpoch}.$extension';
      final path = await _supabase.storage.from('avatars').uploadBinary(
        fileName,
        fileBytes,
        fileOptions: const FileOptions(upsert: true),
      );
      
      final publicUrl = _supabase.storage.from('avatars').getPublicUrl(fileName);
      
      // Actualizar la tabla usuarios en la columna 'foto' (usando user_id)
      await _supabase.from('usuarios').update({'foto': publicUrl}).eq('user_id', userId);
      
      return publicUrl;
    } catch (e) {
      print('Error al subir foto de usuario: $e');
      return null;
    }
  }

  // --- CARRITO ---
  Future<void> syncCart(String userId, List<CartItem> items) async {
    try {
      // Primero eliminamos el carrito anterior del usuario para simplificar la sincronización
      await _supabase.from('carrito').delete().eq('user_id', userId);
      
      final cartData = items.map((item) => {
        'user_id': userId,
        'producto_id': item.id,
        'nombre_producto': item.title,
        'cantidad': item.quantity,
        'precio': item.price,
        'imagen': item.imageUrl,
      }).toList();

      if (cartData.isNotEmpty) {
        await _supabase.from('carrito').insert(cartData);
      }
    } catch (e) {
      print('Error al sincronizar carrito: $e');
    }
  }

  // --- PEDIDOS ---
  Future<String?> createOrder({
    required String userId,
    required double total,
    required List<CartItem> items,
    DateTime? fecha,
    String? direccion,
    String? metodoPago,
    String? telefono,
    String? comentario,
    String? observaciones,
  }) async {
    try {
      // 1. Insertar el pedido (cabecera)
      final orderResponse = await _supabase.from('pedidos').insert({
        'user_id': userId,
        'total': total,
        'fecha': fecha?.toIso8601String(),
        'direccion_entrega': direccion,
        'metodo_pago': metodoPago,
        'telefono_contacto': telefono,
        'comentario': comentario,
        'observaciones': observaciones,
      }).select().single();

      final String pedidoId = orderResponse['id'].toString();

      // 2. Insertar los items del pedido
      final List<Map<String, dynamic>> itemsData = items.map((item) => {
        'pedido_id': int.parse(pedidoId),
        'producto_id': item.id,
        'nombre_producto': item.title,
        'cantidad': item.quantity,
        'precio_unitario': item.price,
      }).toList();

      await _supabase.from('pedido_items').insert(itemsData);

      return pedidoId;
    } catch (e) {
      print('Error al crear pedido en Supabase: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getUserOrders(String userId) async {
    try {
      return await _supabase
          .from('pedidos')
          .select('*, pedido_items(*)')
          .eq('user_id', userId)
          .order('fecha', ascending: false);
    } catch (e) {
      print('Error al obtener historial de pedidos: $e');
      return [];
    }
  }

  Future<List<DateTime>> getReservedDates() async {
    try {
      final data = await _supabase
          .from('pedidos')
          .select('fecha')
          .neq('estado', 'cancelado');
      return (data as List)
          .map((json) => DateTime.parse(json['fecha']))
          .toList();
    } catch (e) {
      print('Error al obtener fechas reservadas: $e');
      return [];
    }
  }

  // --- COMPROBANTES DE PAGOS ---
  Future<String?> uploadReceiptFile(String orderId, dynamic fileBytes, String extension) async {
    try {
      final fileName = '$orderId/receipt_${DateTime.now().millisecondsSinceEpoch}.$extension';
      await _supabase.storage.from('comprobantes').uploadBinary(
        fileName,
        fileBytes,
        fileOptions: const FileOptions(upsert: true),
      );
      
      return _supabase.storage.from('comprobantes').getPublicUrl(fileName);
    } catch (e) {
      print('Error al subir archivo de comprobante: $e');
      return null;
    }
  }

  Future<void> uploadPaymentReceipt(PaymentReceiptModel receipt) async {
    try {
      await _supabase.from('comprobantesPagos').insert(receipt.toJson());
    } catch (e) {
      print('Error al registrar comprobante en DB: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getPaymentReceipt(String orderId) async {
    try {
      final data = await _supabase
          .from('comprobantesPagos')
          .select()
          .eq('order_id', orderId)
          .maybeSingle();
      return data;
    } catch (e) {
      print('Error al obtener comprobante: $e');
      return null;
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _supabase
          .from('pedidos')
          .update({'estado': status})
          .eq('id', int.parse(orderId));
    } catch (e) {
      print('Error al actualizar estado del pedido: $e');
      rethrow;
    }
  }

  Future<void> deleteOrder(String orderId) async {
    try {
      // Al eliminar el pedido, los items se deberían eliminar por cascada en la DB 
      // si está configurada, de lo contrario hay que eliminarlos manualmente.
      // Por seguridad eliminamos ambos.
      await _supabase.from('pedido_items').delete().eq('pedido_id', int.parse(orderId));
      await _supabase.from('pedidos').delete().eq('id', int.parse(orderId));
    } catch (e) {
      print('Error al eliminar pedido: $e');
      rethrow;
    }
  }

  // --- PROFILE ADMIN ---
  Future<ProfileAdminModel?> getAdminProfile() async {
    try {
      final data = await _supabase.from('profile_admin').select().limit(1).maybeSingle();
      if (data != null) return ProfileAdminModel.fromJson(data);
    } catch (e) {
      print('Error al obtener perfil administrativo: $e');
    }
    return null;
  }

  // --- NOTIFICACIONES ---
  Future<void> createNotification({
    String? userId,
    required String title,
    required String message,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _supabase.from('notificaciones').insert({
        'user_id': userId,
        'titulo': title,
        'mensaje': message,
        'tipo': type,
        'data': data,
      });
    } catch (e) {
      print('Error al crear notificación: $e');
    }
  }
}
