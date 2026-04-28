import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database_service.dart';
import '../models/user_model.dart';

class UserProvider extends ChangeNotifier {
  String _id = '';
  String _name = 'Invitado';
  String _email = '';
  String? _photoUrl;
  String _phone = '';
  String _address = '';

  final DatabaseService _dbService = DatabaseService();

  UserProvider() {
    _loadFromPrefs();
  }

  String get id => _id;
  String get name => _name;
  String get email => _email;
  String? get photoUrl => _photoUrl;
  String get phone => _phone;
  String get address => _address;

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _id = prefs.getString('user_id') ?? '';
    _name = prefs.getString('user_name') ?? 'Invitado';
    _email = prefs.getString('user_email') ?? '';
    _photoUrl = prefs.getString('user_photo_url');
    _phone = prefs.getString('user_phone') ?? '';
    _address = prefs.getString('user_address') ?? '';
    notifyListeners();
  }

  void setUser({
    required String id,
    required String name,
    required String email,
    String? photoUrl,
  }) async {
    _id = id;
    _name = name;
    _email = email;
    _photoUrl = photoUrl;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', id);
    await prefs.setString('user_name', name);
    await prefs.setString('user_email', email);
    if (photoUrl != null) {
      await prefs.setString('user_photo_url', photoUrl);
    } else {
      await prefs.remove('user_photo_url');
    }

    // Sincronizar con Supabase (tabla usuarios)
    await _dbService.syncUser(UserModel(
      id: _id,
      email: _email,
      name: _name,
      photoUrl: _photoUrl,
      phone: _phone,
      address: _address,
    ));
    
    notifyListeners();
  }

  void syncWithSupabaseUser(dynamic user) {
    if (user == null) return;
    
    final String id = user.id;
    final String name = user.userMetadata?['full_name'] ?? user.email?.split('@')[0] ?? 'Usuario';
    final String email = user.email ?? '';
    final String? photoUrl = user.userMetadata?['avatar_url'] ?? user.userMetadata?['picture'];

    setUser(id: id, name: name, email: email, photoUrl: photoUrl);
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    required String phone,
    required String address,
  }) async {
    _name = name;
    _email = email;
    _phone = phone;
    _address = address;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    await prefs.setString('user_email', email);
    await prefs.setString('user_phone', phone);
    await prefs.setString('user_address', address);

    // Sincronizar con Supabase
    if (_id.isNotEmpty) {
      await _dbService.syncUser(UserModel(
        id: _id,
        email: _email,
        name: _name,
        photoUrl: _photoUrl,
        phone: _phone,
        address: _address,
      ));
    }
    
    notifyListeners();
  }

  Future<void> updatePhotoUrl(String photoUrl) async {
    _photoUrl = photoUrl;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_photo_url', photoUrl);
    notifyListeners();
  }

  void clearUser() async {
    _id = '';
    _name = 'Invitado';
    _email = '';
    _photoUrl = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_photo_url');
    
    notifyListeners();
  }
}
