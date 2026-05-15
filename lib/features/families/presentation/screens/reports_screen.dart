import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ١. الـ Header المنحني المطور
            ClipPath(
              clipper: HeaderClipper(),
              child: Container(
                height: 300,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    // سهم الرجوع
                    Positioned(
                      top: 50,
                      left: 15,
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),

                    // محتوى الهيدر
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'معدل الإنجاز العام للمركز',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            '٨٥٪',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 60,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'أداء ممتاز هذا الأسبوع',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // ٢. كروت الإحصائيات السريعة
                  Row(
                    children: [
                      _buildSmallStatCard(
                        'نسبة الإنجاز',
                        '٨٨٪',
                        Colors.green,
                        Icons.trending_up,
                      ),
                      const SizedBox(width: 15),
                      _buildSmallStatCard(
                        'حالات جديدة',
                        '٢٤',
                        Colors.blue,
                        Icons.person_add_alt_1,
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // ٣. إحصائيات الأسر (تصميم إحصائي فعلي)
                  const Text(
                    'تحليل توزيع الأسر',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(height: 15),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildFamilyProgressRow(
                          'أسرة الحالات الشديدة',
                          45,
                          154,
                          Colors.red,
                        ),
                        const SizedBox(height: 20),
                        _buildFamilyProgressRow(
                          'أسرة الحالات المتوسطة',
                          72,
                          132,
                          Colors.orange,
                        ),
                        const SizedBox(height: 20),
                        _buildFamilyProgressRow(
                          'أسرة الحالات الضعيفة',
                          28,
                          135,
                          Colors.green,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                  // ٤. تحليل كفاءة النظام (الـ Conflict Logic)
                  const Text(
                    'تحليل كفاءة النظام والتعارضات',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blue.withOpacity(0.1)),
                    ),
                    child: Column(
                      children: [
                        _buildAnalysisRow(
                          'التعارضات التي تم منعها برمجياً',
                          '١٤ حالة',
                          Icons.security,
                          Colors.blue,
                        ),
                        const Divider(height: 30),
                        _buildAnalysisRow(
                          'وقت القاعات الضائع',
                          '٢ ساعة/أسبوع',
                          Icons.hourglass_empty,
                          Colors.orange,
                        ),
                        const Divider(height: 30),
                        _buildAnalysisRow(
                          'متوسط مدة الجلسة',
                          '٤٥ دقيقة',
                          Icons.av_timer,
                          Colors.purple,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ٥. حالة إشغال القاعات
                  const Text(
                    'إحصائيات إشغال القاعات',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildHallStat('قاعة (أ)', '٤٥ ساعة / أسبوع', 0.8),
                  _buildHallStat('قاعة (ب)', '١٢ ساعة / أسبوع', 0.2),
                  _buildHallStat('قاعة (ج)', '٣٠ ساعة / أسبوع', 0.5),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- الودجت الجديدة لتحليل الأسر بشكل إحصائي ---
  Widget _buildFamilyProgressRow(
    String title,
    int count,
    int total,
    Color color,
  ) {
    double percent = count / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${(percent * 100).toInt()}%',
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.circle, size: 10, color: color),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 10,
              width: double.infinity,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Container(
              height: 10,
              width: (percent * 280), // نسبة العرض بناءً على الإحصائية
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '$count حالة من إجمالي $total',
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }

  // الودجتات المساعدة الباقية (كما هي لضمان التناسق)
  Widget _buildSmallStatCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisRow(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const Spacer(),
        Text(
          label,
          style: const TextStyle(color: Colors.black87, fontSize: 13),
        ),
        const SizedBox(width: 12),
        Icon(icon, color: color, size: 22),
      ],
    );
  }

  Widget _buildHallStat(String name, String detail, double usage) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircularProgressIndicator(
            value: usage,
            strokeWidth: 4,
            backgroundColor: Colors.grey.shade200,
            color: Colors.deepPurple,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                detail,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 60,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
