import 'package:flutter/material.dart';

class SettingsProvider with ChangeNotifier {
  bool _isDarkMode = false;
  double _fontSizeMultiplier = 1.0;

  // الحصول على القيم الحالية
  bool get isDarkMode => _isDarkMode;
  double get fontSizeMultiplier => _fontSizeMultiplier;

  // تغيير وضع المظهر (Dark Mode)
  void toggleTheme(bool value) {
    _isDarkMode = value;
    notifyListeners(); // تنبيه كل صفحات التطبيق بالتحديث فوراً
  }

  // تغيير حجم الخط
  void updateFontSize(double value) {
    _fontSizeMultiplier = value;
    notifyListeners(); // تنبيه كل صفحات التطبيق بالتحديث فوراً
  }
}
