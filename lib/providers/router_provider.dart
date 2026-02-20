import 'package:flutter/foundation.dart';

class RouterProvider extends ChangeNotifier {
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  String _authViewMode = 'login'; // 'login' or 'register'
  String get authViewMode => _authViewMode;

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void setAuthViewMode(String mode) {
    if (_authViewMode != mode) {
      _authViewMode = mode;
      notifyListeners();
    }
  }

  void reset() {
    _selectedIndex = 0;
    _authViewMode = 'login';
    notifyListeners();
  }
}
