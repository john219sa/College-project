import 'package:flutter/material.dart';

enum UserRole {
  admin, // مسؤول عامل
  familyManager, // مسؤول أسرة
  assistant, // مساعد
  specialist, // أخصائي
  parent, // أهل
}

class ChildDetailsScreen extends StatefulWidget {
  final String childName;
  final UserRole currentUserRole;

  const ChildDetailsScreen({
    super.key,
    required this.childName,
    required this.currentUserRole,
  });

  @override
  State<ChildDetailsScreen> createState() => _ChildDetailsScreenState();
}

class _ChildDetailsScreenState extends State<ChildDetailsScreen> {
  // ================= الصلاحيات =================

  bool get canEditTreatment =>
      widget.currentUserRole == UserRole.admin ||
      widget.currentUserRole == UserRole.familyManager ||
      widget.currentUserRole == UserRole.assistant ||
      widget.currentUserRole == UserRole.specialist;

  bool get canEditReports =>
      widget.currentUserRole == UserRole.admin ||
      widget.currentUserRole == UserRole.familyManager ||
      widget.currentUserRole == UserRole.assistant ||
      widget.currentUserRole == UserRole.specialist;

  bool get canAddExercises =>
      widget.currentUserRole == UserRole.admin ||
      widget.currentUserRole == UserRole.specialist;

  bool get canAddComment => true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),

      floatingActionButton: canAddComment
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF2575FC),
              onPressed: () {},
              child: const Icon(Icons.add_comment),
            )
          : null,

      body: SingleChildScrollView(
        child: Column(
          children: [
            // ================= HEADER =================
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

                      Center(
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: const [
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
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      Text(
                        widget.childName,
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

            // ================= BODY =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // ================= المعلومات الأساسية =================
                  _buildDetailCard(
                    title: 'المعلومات الأساسية',
                    icon: Icons.info_outline,
                    children: [
                      _buildInfoRow('السن:', '٧ سنوات'),
                      _buildInfoRow('العنوان:', 'القاهرة'),
                      _buildInfoRow('نوع الحالة:', 'توحد - درجة متوسطة'),
                    ],
                  ),

                  // ================= الأخصائيين =================
                  _buildDetailCard(
                    title: 'الأخصائيين المتابعين',
                    icon: Icons.medical_services_outlined,
                    children: [
                      _buildInfoRow('أخصائي تخاطب:', 'د. أحمد علي'),
                      _buildInfoRow('أخصائي نفسي:', 'د. سارة محمد'),
                    ],
                  ),

                  // ================= التقرير =================
                  _buildDetailCard(
                    title: 'تقرير الحالة',
                    icon: Icons.analytics_outlined,

                    action: canEditReports
                        ? IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.edit),
                          )
                        : null,

                    children: const [
                      Text(
                        'يوجد تحسن ملحوظ في التواصل البصري واستجابة الطفل.',
                        style: TextStyle(height: 1.5),
                      ),
                    ],
                  ),

                  // ================= العلاج =================
                  _buildDetailCard(
                    title: 'الخطة العلاجية',
                    icon: Icons.healing,

                    action: canEditTreatment
                        ? IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.edit),
                          )
                        : null,

                    children: [
                      _buildBulletPoint('جلسات تخاطب ٣ مرات أسبوعياً'),
                      _buildBulletPoint('تقليل وقت الشاشات'),
                    ],

                    color: Colors.orange,
                  ),

                  // ================= التمارين =================
                  _buildDetailCard(
                    title: 'التمارين',
                    icon: Icons.fitness_center,

                    action: canAddExercises
                        ? IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.add),
                          )
                        : null,

                    children: [
                      _buildBulletPoint('تمرين تركيز لمدة ١٥ دقيقة'),
                      _buildBulletPoint('تمرين نطق الحروف'),
                    ],

                    color: Colors.deepPurple,
                  ),

                  // ================= الأشعات =================
                  _buildDetailCard(
                    title: 'الأشعات',
                    icon: Icons.image,

                    action: canEditReports
                        ? IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.upload_file),
                          )
                        : null,

                    children: [_buildFileItem('MRI Brain Scan.pdf')],

                    color: Colors.teal,
                  ),

                  // ================= التحاليل =================
                  _buildDetailCard(
                    title: 'التحاليل',
                    icon: Icons.science,

                    action: canEditReports
                        ? IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.upload),
                          )
                        : null,

                    children: [_buildFileItem('Blood Test.pdf')],

                    color: Colors.redAccent,
                  ),

                  // ================= التعليقات =================
                  _buildDetailCard(
                    title: 'التواصل والتعليقات',
                    icon: Icons.comment_outlined,

                    action: canAddComment
                        ? IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.add_comment),
                          )
                        : null,

                    children: [
                      _buildComment(
                        'الأهل',
                        'الطفل بدأ ينطق كلمات جديدة اليوم',
                      ),

                      _buildComment(
                        'الأخصائي',
                        'ممتاز، هنركز على زيادة التفاعل',
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

  // ================= CARD =================

  Widget _buildDetailCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    Color color = const Color(0xFF6A11CB),
    Widget? action,
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
              Icon(icon, color: color),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),

              if (action != null) action,
            ],
          ),

          const Divider(height: 25),

          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),

          const SizedBox(width: 8),

          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),

          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildComment(String author, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            author,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),

          const SizedBox(height: 5),

          Text(text),
        ],
      ),
    );
  }

  Widget _buildFileItem(String fileName) {
    return ListTile(
      contentPadding: EdgeInsets.zero,

      leading: const Icon(Icons.picture_as_pdf, color: Colors.red),

      title: Text(fileName),

      trailing: IconButton(onPressed: () {}, icon: const Icon(Icons.download)),
    );
  }
}

// ================= HEADER CLIPPER =================

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
