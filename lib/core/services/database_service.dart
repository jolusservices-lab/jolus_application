import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/service_model.dart';

class DatabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Obtiene todos los productos de la tabla 'productos'
  Future<List<ServiceModel>> getProducts() async {
    try {
      final data = await _supabase
          .from('productos')
          .select('*')
          .order('nombre');
      
      return (data as List).map((json) => ServiceModel.fromJson(json)).toList();
    } catch (e) {
      print('Error al obtener productos: $e');
      return [];
    }
  }

  /// Obtiene productos filtrados por el tipo de servicio
  Future<List<ServiceModel>> getProductsByService(String serviceType) async {
    try {
      final data = await _supabase
          .from('productos')
          .select('*')
          .ilike('servicio', serviceType);
      
      return (data as List).map((json) => ServiceModel.fromJson(json)).toList();
    } catch (e) {
      print('Error al filtrar productos por servicio: $e');
      return [];
    }
  }
}
