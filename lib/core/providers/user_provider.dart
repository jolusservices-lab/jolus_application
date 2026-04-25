import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  String _name = 'Javier Oliveras';
  String _email = 'javier.oliveras@example.com';
  String _phone = '+34 612 345 678';
  String _address = 'Calle Principal 123, Madrid';

  UserProvider() {
    _loadFromPrefs();
  }

  String get name => _name;
  String get email => _email;
  String get phone => _phone;
  String get address => _address;

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _name = prefs.getString('user_name') ?? _name;
    _email = prefs.getString('user_email') ?? _email;
    _phone = prefs.getString('user_phone') ?? _phone;
    _address = prefs.getString('user_address') ?? _address;
    notifyListeners();
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
    
    notifyListeners();
  }
}
