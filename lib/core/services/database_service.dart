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
      
      // Actualizar la tabla usuarios en la columna 'foto'
      await _supabase.from('usuarios').update({'foto': publicUrl}).eq('id', userId);
      
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
        'nombre': item.title,
        'cantidad': item.quantity,
        'precio': item.price,
        'imagen_url': item.imageUrl,
      }).toList();

      if (cartData.isNotEmpty) {
        await _supabase.from('carrito').insert(cartData);
      }
    } catch (e) {
      print('Error al sincronizar carrito: $e');
    }
  }

  // --- COMPROBANTES DE PAGOS ---
  Future<void> uploadPaymentReceipt(PaymentReceiptModel receipt) async {
    try {
      await _supabase.from('comprobantesPagos').insert(receipt.toJson());
    } catch (e) {
      print('Error al subir comprobante: $e');
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
}
