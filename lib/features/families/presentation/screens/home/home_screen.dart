import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../children/children_list_screen.dart';
import '../../../../../shared/widgets/custom_drawer.dart';

import '../../../../../core/constants/api_constants.dart';

import '../psychologists/psychologist_screen.dart';
import '../waiting_list_screen.dart';
import '../reports_screen.dart';
import '../notifications_screen.dart';
import '../schedule_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int childrenCount = 0;

  int specialistsCount = 0;

  bool isLoading = true;

  // ================= GET DASHBOARD STATS =================

  Future<void> fetchDashboardStats() async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/dashboard_stats.php"),
      );

      final data = jsonDecode(response.body);

      if (data['status'] == true) {
        setState(() {
          childrenCount = data['children_count'];

          specialistsCount = data['specialists_count'];

          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    fetchDashboardStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),

      drawer: const CustomSideMenu(),

      body: SingleChildScrollView(
        child: Column(
          children: [
            ClipPath(
              clipper: HeaderClipper(),

              child: Container(
                height: 280,

                width: double.infinity,

                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],

                    begin: Alignment.topLeft,

                    end: Alignment.bottomRight,
                  ),
                ),

                child: SafeArea(
                  child: Stack(
                    children: [
                      Positioned(
                        top: 10,

                        right: 15,

                        child: Builder(
                          builder: (context) => IconButton(
                            icon: const Icon(
                              Icons.menu,
                              color: Colors.white,
                              size: 30,
                            ),

                            onPressed: () => Scaffold.of(context).openDrawer(),
                          ),
                        ),
                      ),

                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [
                          const SizedBox(width: double.infinity),

                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,

                              border: Border.all(color: Colors.white, width: 3),
                            ),

                            child: const CircleAvatar(
                              radius: 50,

                              backgroundColor: Colors.white24,

                              child: Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          const Text(
                            'م. جون صفوت',

                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 4),

                          const Text(
                            'مدير النظام',

                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),

              child: Column(
                children: [
                  // ================= STATS =================
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Row(
                          children: [
                            _buildStatCard(
                              childrenCount.toString(),
                              'عدد الأطفال',
                              Colors.orange,
                            ),

                            const SizedBox(width: 15),

                            _buildStatCard(
                              specialistsCount.toString(),
                              'عدد الأخصائيين',
                              Colors.blue,
                            ),
                          ],
                        ),

                  const SizedBox(height: 35),

                  const Center(
                    child: Text(
                      'الوصول السريع',

                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                    childAspectRatio: 1.4,

                    children: [
                      // إضافة حالة
                      _buildGridItem(
                        'قائمه الانتظار ',
                        Icons.person_add_rounded,
                        Colors.green,

                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const WaitingListScreen(),
                            ),
                          );
                        },
                      ),

                      // التقارير
                      _buildGridItem(
                        'التقارير',
                        Icons.insert_chart_outlined,
                        Colors.purple,

                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ReportsScreen(),
                            ),
                          );
                        },
                      ),

                      // الجدول
                      _buildGridItem(
                        'الجدول',
                        Icons.event_note_rounded,
                        Colors.red,

                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ScheduleScreen(),
                            ),
                          );
                        },
                      ),

                      // الإشعارات
                      _buildGridItem(
                        'الإشعارات',
                        Icons.notifications_active_outlined,
                        Colors.amber,

                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotificationsScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  const Center(
                    child: Text(
                      'إدارة الأسر',

                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  _buildFamilyTile(
                    context,
                    'أسرة الحالات الشديدة',
                    'أمين: م. مينا',
                    Colors.red,
                    15,
                    8,
                    1,
                  ),

                  _buildFamilyTile(
                    context,
                    'أسرة الحالات المتوسطة',
                    'أمين: م. جاسر',
                    Colors.orange,
                    22,
                    12,
                    2,
                  ),

                  _buildFamilyTile(
                    context,
                    'أسرة الحالات الضعيفة',
                    'أمين: مايكل',
                    Colors.green,
                    30,
                    15,
                    3,
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= GRID ITEM =================

  Widget _buildGridItem(
    String title,
    IconData icon,
    Color color, {
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),

      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(20),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
            ),
          ],
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(icon, color: color, size: 35),

            const SizedBox(height: 8),

            Text(
              title,

              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  // ================= STAT CARD =================

  Widget _buildStatCard(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(20),

          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 10),
          ],
        ),

        child: Column(
          children: [
            Text(
              value,

              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              label,

              style: const TextStyle(color: Colors.blueGrey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  // ================= FAMILY TILE =================

  Widget _buildFamilyTile(
    BuildContext context,
    String title,
    String subtitle,
    Color color,
    int childrenCount,
    int specialistsCount,
    int familyId,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 5),
        ],
      ),

      child: ListTile(
        onTap: () {
          Navigator.push(
            context,

            MaterialPageRoute(
              builder: (context) =>
                  ChildrenListScreen(familyId: familyId, familyName: title),
            ),
          );
        },

        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),

          child: Icon(Icons.groups_rounded, color: color),
        ),

        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(subtitle),

            const SizedBox(height: 4),

            Row(
              children: [
                Text(
                  'الأطفال: $childrenCount',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),

                const SizedBox(width: 15),

                Text(
                  'الأخصائيين: $specialistsCount',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ],
            ),
          ],
        ),

        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: Colors.grey,
        ),
      ),
    );
  }
}

// ================= HEADER =================

class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    path.lineTo(0, size.height - 50);

    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 50,
    );

    path.lineTo(size.width, 0);

    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
