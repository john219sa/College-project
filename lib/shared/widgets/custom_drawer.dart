import 'package:college_project/features/families/presentation/screens/auth/login_screen.dart';
import 'package:college_project/shared/widgets/settings_screen.dart';
import 'package:flutter/material.dart';

import '../../features/families/presentation/screens/about/about_us_page.dart';
import '../../features/families/presentation/screens/children/children_list_screen.dart';
import '../../features/families/presentation/screens/home/home_screen.dart';
import '../../features/families/presentation/screens/psychologists/specialist_curriculum_screens.dart';
import '../../features/families/presentation/screens/psychologists/Specialists_manage_screen.dart';
import '../../features/families/presentation/screens/schedule_screen.dart';

class CustomSideMenu extends StatelessWidget {
  const CustomSideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
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
                  page: const ScheduleScreen(specialistId: 0),
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

                _buildMenuItem(
                  context,
                  Icons.upload_file_rounded,
                  "رفع المنهج",
                  iconColor: Colors.indigo,
                  page: const SpecialistSelectionScreen(),
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

                _buildMenuItem(
                  context,
                  Icons.medical_services_rounded,
                  "إدارة الأخصائيين",
                  iconColor: const Color(0xFF6A11CB),
                  page: const TherapistsScreen(),
                ),

                // ✅ الأسر مع familyId صح وnavigation شغال
                _buildFamilyItem(
                  context,
                  "أسر الحالات الشديدة",
                  Colors.red.shade100,
                  Colors.red,
                  familyId: 1,
                  familyName: 'أسرة الحالات الشديدة',
                ),

                _buildFamilyItem(
                  context,
                  "أسر الحالات المتوسطة",
                  Colors.orange.shade100,
                  Colors.orange,
                  familyId: 2,
                  familyName: 'أسرة الحالات المتوسطة',
                ),

                _buildFamilyItem(
                  context,
                  "أسر الحالات الضعيفة",
                  Colors.green.shade100,
                  Colors.green,
                  familyId: 3,
                  familyName: 'أسرة الحالات الضعيفة',
                ),
              ],
            ),
          ),

          const Divider(),

          _buildMenuItem(
            context,
            Icons.settings_suggest_rounded,
            "الإعدادات",
            page: const SettingsScreen(),
          ),

          _buildMenuItem(
            context,
            Icons.logout_rounded,
            "تسجيل الخروج",
            iconColor: Colors.red,
            isLogout: true,
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
    bool isLogout = false,
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
        if (isLogout) {
          _showLogoutDialog(context);
        } else if (page != null) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
        }
      },
    );
  }

  // ✅ widget منفصل للأسر - بيفتح ChildrenListScreen مع familyId الصح
  Widget _buildFamilyItem(
    BuildContext context,
    String title,
    Color bgColor,
    Color iconColor, {
    required int familyId,
    required String familyName,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: bgColor,
        radius: 16,
        child: Icon(Icons.group_rounded, size: 18, color: iconColor),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ChildrenListScreen(familyId: familyId, familyName: familyName),
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'تأكيد تسجيل الخروج',
            textAlign: TextAlign.right,
            style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
          ),
          content: const Text(
            'هل أنت متأكد من رغبتك في تسجيل الخروج؟',
            textAlign: TextAlign.right,
            style: TextStyle(fontFamily: 'Cairo', color: Colors.black54),
          ),
          actionsAlignment: MainAxisAlignment.start,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'لا',
                style: TextStyle(
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: const Text(
                'نعم',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
