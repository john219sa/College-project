import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5), // لون خلفية هادئ
      appBar: AppBar(
        title: const Text(
          'التنبيهات والإشعارات',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 4,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          _buildModernNotify(
            title: 'تعارض في المواعيد!',
            message: 'القاعة (أ) محجوزة بالفعل في توقت جلسة سارة.',
            time: 'منذ ٥ دقائق',
            icon: Icons.error_outline_rounded,
            color: Colors.redAccent,
            tag: 'تنبيه هام',
          ),
          _buildModernNotify(
            title: 'تم تسجيل حالة جديدة',
            message: 'تمت إضافة الطفل "ياسين محمد" لقائمة الانتظار بنجاح.',
            time: 'منذ ساعة',
            icon: Icons.person_add_alt_1_rounded,
            color: Colors.blueAccent,
            tag: 'تحديث',
          ),
          _buildModernNotify(
            title: 'تذكير بالجدول',
            message: 'لديك ٣ جلسات لم تكتمل في جدول اليوم.',
            time: 'منذ ساعتين',
            icon: Icons.event_note_rounded,
            color: Colors.orangeAccent,
            tag: 'تذكير',
          ),
          _buildModernNotify(
            title: 'اكتملت الجلسة',
            message: 'تم إنهاء جلسة التخاطب للطفل أحمد بنجاح.',
            time: 'منذ ٤ ساعات',
            icon: Icons.check_circle_outline_rounded,
            color: Colors.green,
            tag: 'نجاح',
          ),
        ],
      ),
    );
  }

  Widget _buildModernNotify({
    required String title,
    required String message,
    required String time,
    required IconData icon,
    required Color color,
    required String tag,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(color: color, width: 6),
            ), // خط ملون جانبي
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الوقت والأيقونة
              Column(
                children: [
                  CircleAvatar(
                    backgroundColor: color.withOpacity(0.1),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    time,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // النصوص
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              color: color,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      message,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
