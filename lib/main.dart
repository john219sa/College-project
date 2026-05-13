import 'package:flutter/material.dart';
import 'features/families/presentation/screens/auth/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CareBridge',

      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Cairo'),

      // البداية من صفحة تسجيل الدخول
      home: const LoginScreen(),
    );
  }
}
