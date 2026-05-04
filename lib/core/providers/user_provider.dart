import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database_service.dart';
import '../models/user_model.dart';

class UserProvider extends ChangeNotifier {
  String _id = '';
  String _name = 'Invitado';
  String _subname = '';
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
  String get subname => _subname;
  String get email => _email;
  String? get photoUrl => _photoUrl;
  String get phone => _phone;
  String get address => _address;

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _id = prefs.getString('user_id') ?? '';
    _name = prefs.getString('user_name') ?? 'Invitado';
    _subname = prefs.getString('user_subname') ?? '';
    _email = prefs.getString('user_email') ?? '';
    _photoUrl = prefs.getString('user_photo_url');
    _phone = prefs.getString('user_phone') ?? '';
    _address = prefs.getString('user_address') ?? '';
    notifyListeners();
  }

  Future<void> setUser({
    required String id,
    required String name,
    required String email,
    String? subname,
    String? photoUrl,
    String? phone,
    String? address,
  }) async {
    _id = id;
    _name = name;
    _email = email;
    _photoUrl = photoUrl;
    if (subname != null) _subname = subname;
    if (phone != null) _phone = phone;
    if (address != null) _address = address;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', id);
    await prefs.setString('user_name', _name);
    await prefs.setString('user_subname', _subname);
    await prefs.setString('user_email', _email);
    await prefs.setString('user_phone', _phone);
    await prefs.setString('user_address', _address);

    if (_photoUrl != null) {
      await prefs.setString('user_photo_url', _photoUrl!);
    } else {
      await prefs.remove('user_photo_url');
    }
    
    notifyListeners();
  }

  Future<void> syncWithSupabaseUser(dynamic user) async {
    if (user == null) return;
    
    final String id = user.id;
    final String name = user.userMetadata?['full_name'] ?? user.email?.split('@')[0] ?? 'Usuario';
    final String email = user.email ?? '';
    final String? photoUrl = user.userMetadata?['avatar_url'] ?? user.userMetadata?['picture'];

    await setUser(id: id, name: name, email: email, photoUrl: photoUrl);

    try {
      await _dbService.syncUser(UserModel(
        id: id,
        email: email,
        name: name,
        photoUrl: photoUrl,
        subname: '',
        phone: '',
        address: '',
      ));
      debugPrint('Sincronización exitosa con la tabla usuarios');
    } catch (e) {
      debugPrint('Error crítico sincronizando usuario: $e');
    }
  }

  Future<void> updateProfile({
    required String name,
    required String subname,
    required String email,
    required String phone,
    required String address,
  }) async {
    _name = name;
    _subname = subname;
    _email = email;
    _phone = phone;
    _address = address;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    await prefs.setString('user_subname', subname);
    await prefs.setString('user_email', email);
    await prefs.setString('user_phone', phone);
    await prefs.setString('user_address', address);

    if (_id.isNotEmpty) {
      await _dbService.syncUser(UserModel(
        id: _id,
        email: _email,
        name: _name,
        subname: _subname,
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

  Future<void> clearUser() async {
    _id = '';
    _name = 'Invitado';
    _subname = '';
    _email = '';
    _photoUrl = null;
    _phone = '';
    _address = '';
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    notifyListeners();
  }
}
