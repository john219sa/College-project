import 'package:college_project/shared/widgets/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/families/presentation/screens/auth/login_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => SettingsProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // استماع للتغييرات في الـ Provider
    final settings = Provider.of<SettingsProvider>(context);

    return MaterialApp(
      title: 'College Project',
      debugShowCheckedModeBanner: false,

      // إعدادات الثيم (الـ Dark والـ Light) بناءً على حالة الـ Provider
      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,

      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF4F7FA),
        // نضرب حجم الخط الافتراضي في القيمة اللي اختارها المستخدم
        textTheme: TextTheme(
          bodyLarge: TextStyle(
            fontSize: 16 * settings.fontSizeMultiplier,
            fontFamily: 'Cairo',
          ),
          bodyMedium: TextStyle(
            fontSize: 14 * settings.fontSizeMultiplier,
            fontFamily: 'Cairo',
          ),
          titleLarge: TextStyle(
            fontSize: 18 * settings.fontSizeMultiplier,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
          ),
        ),
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        // إعدادات خطوط الوضع المظلم
        textTheme: TextTheme(
          bodyLarge: TextStyle(
            fontSize: 16 * settings.fontSizeMultiplier,
            fontFamily: 'Cairo',
          ),
          bodyMedium: TextStyle(
            fontSize: 14 * settings.fontSizeMultiplier,
            fontFamily: 'Cairo',
          ),
          titleLarge: TextStyle(
            fontSize: 18 * settings.fontSizeMultiplier,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
          ),
        ),
      ),

      home: const LoginScreen(),
    );
  }
}
