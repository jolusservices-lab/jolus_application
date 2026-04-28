class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? subname;
  final String? phone;
  final String? address;
  final String? photoUrl;

  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.subname,
    this.phone,
    this.address,
    this.photoUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['user_id'] ?? json['id'] ?? '',
      email: json['correo'] ?? json['email'] ?? '',
      name: json['nombres'] ?? json['name'],
      subname: json['apellidos'] ?? json['subname'],
      phone: json['telefono'] ?? json['phone'],
      address: json['direccion'] ?? json['address'],
      photoUrl: json['foto'] ?? json['photo_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': id, // Cambiado de 'id' a 'user_id' para coincidir con la BD
      'correo': email,
      'nombres': name,
      'apellidos': subname,
      'telefono': phone,
      'direccion': address,
      'foto': photoUrl,
    };
  }
}
