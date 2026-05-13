import 'package:flutter/material.dart';

class ChildDetailsScreen extends StatelessWidget {
  final String childName;

  const ChildDetailsScreen({super.key, required this.childName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ================= HEADER (نفس تصميم الهوم) =================
            Stack(
              children: [
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
                  ),
                ),
                SafeArea(
                  child: Column(
                    children: [
                      // زر الرجوع
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      // صورة الطفل
                      Center(
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(color: Colors.black26, blurRadius: 10),
                            ],
                          ),
                          child: const CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.white24,
                            child: Icon(
                              Icons.face_retouching_natural,
                              size: 70,
                              color: Colors.white,
                            ),
                            // هنا يمكن وضع صورة الطفل الحقيقية:
                            // backgroundImage: AssetImage('assets/child_image.png'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        childName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ================= BODY CONTENT =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // 1. المعلومات الأساسية
                  _buildDetailCard('المعلومات الأساسية', Icons.info_outline, [
                    _buildInfoRow('السن:', '٧ سنوات'),
                    _buildInfoRow('العنوان:', 'القاهرة، مدينة نصر'),
                    _buildInfoRow('الإعاقة:', 'توحد (درجة متوسطة)'),
                  ]),

                  // 2. الأخصائيين المتابعين
                  _buildDetailCard(
                    'الأخصائيين المتابعين',
                    Icons.medical_services_outlined,
                    [
                      _buildInfoRow('أخصائي تخاطب:', 'د. أحمد علي'),
                      _buildInfoRow('أخصائي نفسي:', 'د. سارة محمد'),
                    ],
                  ),

                  // 3. تقرير الحالة
                  _buildDetailCard(
                    'تقرير الحالة (التقدم)',
                    Icons.analytics_outlined,
                    [
                      const Text(
                        'هناك تحسن ملحوظ في التواصل البصري واستجابة الطفل للأوامر البسيطة خلال الشهر الماضي.',
                        style: TextStyle(height: 1.5, color: Colors.black87),
                      ),
                    ],
                  ),

                  // 4. العلاج والتمارين
                  _buildDetailCard(
                    'البرنامج العلاجي والتمارين',
                    Icons.fitness_center,
                    [
                      _buildBulletPoint('تمارين التركيز لمدة ١٥ دقيقة يومياً.'),
                      _buildBulletPoint('جلسات تخاطب (٣ مرات أسبوعياً).'),
                      _buildBulletPoint(
                        'تجنب الشاشات والمثيرات البصرية العالية.',
                      ),
                    ],
                    color: Colors.orange,
                  ),

                  // 5. التعليقات (المستقبلية)
                  _buildDetailCard(
                    'سجل التواصل والتعليقات',
                    Icons.comment_outlined,
                    [
                      _buildComment(
                        'الأهل:',
                        'الطفل بدأ ينطق كلمات بسيطة في البيت اليوم.',
                      ),
                      _buildComment(
                        'الأخصائي:',
                        'ممتاز، سنركز في الجلسة القادمة على زيادة الحصيلة اللغوية.',
                      ),
                    ],
                    color: Colors.green,
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- أدوات بناء التصميم (Helper Widgets) ---

  Widget _buildDetailCard(
    String title,
    IconData icon,
    List<Widget> children, {
    Color color = const Color(0xFF6A11CB),
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const Divider(height: 25, thickness: 0.5),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(width: 8),
          Text(value, style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Expanded(child: Text(text, style: const TextStyle(height: 1.4))),
        ],
      ),
    );
  }

  Widget _buildComment(String author, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            author,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

// ================= HEADER CLIPPER (نفس الموجود في الهوم) =================
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
