class ServiceModel {
  final String id;
  final String nombre;
  final int cantidad;
  final String descripcion;
  final String categoria; // Basico, Premium, VIP
  final String servicio;  // Decoraciones, Buffet, etc.
  final double precio;
  final String? imagen;
  final String? productoId;

  ServiceModel({
    required this.id,
    required this.nombre,
    required this.cantidad,
    required this.descripcion,
    required this.categoria,
    required this.servicio,
    required this.precio,
    this.imagen,
    this.productoId,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'].toString(),
      nombre: json['nombre'] ?? 'Sin nombre',
      cantidad: json['cantidad'] ?? 0,
      descripcion: json['descripcion'] ?? '',
      categoria: json['categoria'] ?? 'Basico',
      servicio: json['servicio'] ?? 'General',
      precio: (json['precio'] ?? 0).toDouble(),
      imagen: json['imagen'],
      productoId: json['producto_id']?.toString(),
    );
  }
}
