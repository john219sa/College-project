import 'package:flutter/material.dart';

import '../../features/families/presentation/screens/about/about_us_page.dart';
import '../../features/families/presentation/screens/home/home_screen.dart';
import '../../features/families/presentation/screens/schedule_screen.dart';

class CustomSideMenu extends StatelessWidget {
  const CustomSideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // رأس القائمة مع التدرج اللوني
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
                backgroundImage: AssetImage('assets/images/Logo.jpeg'),
              ),
            ),
            accountName: const Text(
              "م. جون صفوت",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                fontFamily: 'Cairo',
              ),
            ),
            accountEmail: const Text(
              "مدير النظام",
              style: TextStyle(fontFamily: 'Cairo'),
            ),
          ),

          // قائمة العناصر
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(
                  context,
                  Icons.dashboard_rounded,
                  "الرئيسية",
                  isSelected: true,
                  page: const HomeScreen(),
                ),

                _buildMenuItem(
                  context,
                  Icons.calendar_month_rounded,
                  "الجدول الزمني",
                  page: const ScheduleScreen(),
                ),

                _buildMenuItem(
                  context,
                  Icons.info_rounded,
                  "عن المركز",
                  page: const AboutUsPage(),
                ),

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
                  context,
                  Icons.person_add_alt_1_rounded,
                  "إضافة حالة جديدة",
                  iconColor: Colors.green,
                ),

                _buildMenuItem(
                  context,
                  Icons.assignment_rounded,
                  "سجل الحالات",
                ),

                _buildMenuItem(
                  context,
                  Icons.analytics_rounded,
                  "التقارير والإحصائيات",
                ),

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
                  context,
                  "أسر الحالات الشديدة",
                  Colors.red.shade100,
                  Colors.red,
                ),

                _buildCategoryItem(
                  context,
                  "أسر الحالات المتوسطة",
                  Colors.orange.shade100,
                  Colors.orange,
                ),

                _buildCategoryItem(
                  context,
                  "أسر الحالات الضعيفة",
                  Colors.green.shade100,
                  Colors.green,
                ),
              ],
            ),
          ),

          // التذييل
          const Divider(),

          _buildMenuItem(context, Icons.settings_suggest_rounded, "الإعدادات"),

          _buildMenuItem(
            context,
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
    BuildContext context,
    IconData icon,
    String title, {
    Color? iconColor,
    bool isSelected = false,
    Widget? page,
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

      onTap: () {
        Navigator.pop(context);

        if (page != null) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
        }
      },
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    String title,
    Color bgColor,
    Color iconColor,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: bgColor,
        radius: 16,
        child: Icon(Icons.group_rounded, size: 18, color: iconColor),
      ),

      title: Text(title, style: const TextStyle(fontSize: 14)),

      onTap: () {
        Navigator.pop(context);
      },
    );
  }
}
