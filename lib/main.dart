import 'package:flutter/material.dart';
import 'features/families/presentation/screens/families_manager_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'مركز الأمل',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Cairo', // تأكد من إضافة الخط في pubspec لو أردت استخدامه
      ),
      // نقطة الانطلاق هي الشاشة الرئيسية
      home: const FamiliesManagerScreen(),
    );
  }
}
