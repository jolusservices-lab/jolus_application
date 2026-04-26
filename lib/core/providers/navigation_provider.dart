import 'package:flutter/material.dart';

class NavigationProvider with ChangeNotifier {
  int _selectedIndex = 0;
  String _selectedCategory = 'Todos';

  int get selectedIndex => _selectedIndex;
  String get selectedCategory => _selectedCategory;

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    _selectedIndex = 1; // Always jump to Services tab when a category is selected
    notifyListeners();
  }
}
