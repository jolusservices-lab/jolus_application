class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? phone;
  final String? address;
  final String? photoUrl;

  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.phone,
    this.address,
    this.photoUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['correo_electronico'] ?? json['email'] ?? '',
      name: json['nombre_apellido'] ?? json['name'],
      phone: json['telefono'] ?? json['phone'],
      address: json['direccion'] ?? json['address'],
      photoUrl: json['url_foto'] ?? json['photo_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'correo_electronico': email,
      'nombre_apellido': name,
      'telefono': phone,
      'direccion': address,
      'url_foto': photoUrl,
    };
  }
}
