import 'package:flutter/material.dart';

class CustomSideMenu extends StatelessWidget {
  const CustomSideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // رأس القائمة مع التدرج اللوني (كما في Screenshot 2026-05-13 181110.png)
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 35,
                backgroundImage: AssetImage(
                  'assets/images/Logo.jpeg',
                ), // استخدام شعارك من image_2c2e17.png
              ),
            ),
            accountName: const Text(
              "م. جون صفوت",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                fontFamily:
                    'Cairo', // تأكد من إضافة الخط العربي في pubspec.yaml
              ),
            ),
            accountEmail: const Text(
              "مدير النظام",
              style: TextStyle(fontFamily: 'Cairo'),
            ),
          ),

          // قائمة العناصر القابلة للتمرير
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(
                  Icons.dashboard_rounded,
                  "الرئيسية",
                  isSelected: true,
                ),
                _buildMenuItem(Icons.calendar_month_rounded, "الجدول الزمني"),

                const Divider(indent: 20, endIndent: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    "العمليات",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                _buildMenuItem(
                  Icons.person_add_alt_1_rounded,
                  "إضافة حالة جديدة",
                  iconColor: Colors.green,
                ),
                _buildMenuItem(Icons.assignment_rounded, "سجل الحالات"),
                _buildMenuItem(Icons.analytics_rounded, "التقارير والإحصائيات"),

                const Divider(indent: 20, endIndent: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    "الإدارة",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                _buildCategoryItem(
                  "أسر الحالات الشديدة",
                  Colors.red.shade100,
                  Colors.red,
                ),
                _buildCategoryItem(
                  "أسر الحالات المتوسطة",
                  Colors.orange.shade100,
                  Colors.orange,
                ),
                _buildCategoryItem(
                  "أسر الحالات الضعيفة",
                  Colors.green.shade100,
                  Colors.green,
                ),
              ],
            ),
          ),

          // التذييل (الإعدادات وتسجيل الخروج)
          const Divider(),
          _buildMenuItem(Icons.settings_suggest_rounded, "الإعدادات"),
          _buildMenuItem(
            Icons.logout_rounded,
            "تسجيل الخروج",
            iconColor: Colors.red,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title, {
    Color? iconColor,
    bool isSelected = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? const Color(0xFF2575FC)),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? const Color(0xFF2575FC) : Colors.black87,
        ),
      ),
      tileColor: isSelected ? Colors.blue.withOpacity(0.1) : null,
      onTap: () {},
    );
  }

  Widget _buildCategoryItem(String title, Color bgColor, Color iconColor) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: bgColor,
        radius: 16,
        child: Icon(Icons.group_rounded, size: 18, color: iconColor),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      onTap: () {},
    );
  }
}
