import 'package:flutter/material.dart';

class PsychologistScreen extends StatelessWidget {
  const PsychologistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),

      appBar: AppBar(
        title: const Text('صفحة الأخصائي النفسي'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),

        children: [
          // ================= WORK HOURS CARD =================
          _buildWorkHoursCard(),

          const SizedBox(height: 20),

          // ================= TITLE =================
          const Text(
            "الجلسات الأسبوعية",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.right,
          ),

          const Divider(),

          // ================= SESSIONS =================
          _buildSessionTile(
            context,
            "الجلسة الأولى: الأحد",
            "موضوع الجلسة: التقييم السلوكي",
          ),

          _buildSessionTile(
            context,
            "الجلسة الثانية: الثلاثاء",
            "موضوع الجلسة: تنمية المهارات",
          ),

          _buildSessionTile(
            context,
            "الجلسة الثالثة: الخميس",
            "موضوع الجلسة: المتابعة الختامية",
          ),
        ],
      ),
    );
  }

  // ================= WORK HOURS CARD =================

  Widget _buildWorkHoursCard() {
    return Card(
      elevation: 4,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

      child: const Padding(
        padding: EdgeInsets.all(16),

        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.access_time_filled, color: Colors.blue),

                SizedBox(width: 10),

                Text(
                  "مواعيد العمل بالمركز",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),

            SizedBox(height: 10),

            Text("الأحد - الثلاثاء - الخميس"),

            SizedBox(height: 5),

            Text("من الساعة 4:00 عصراً حتى 9:00 مساءً"),
          ],
        ),
      ),
    );
  }

  // ================= SESSION TILE =================

  Widget _buildSessionTile(
    BuildContext context,
    String title,
    String subtitle,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),

      child: ExpansionTile(
        leading: const Icon(Icons.event_note, color: Colors.blueAccent),

        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),

        subtitle: Text(subtitle),

        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

            child: Column(
              children: [
                // ================= PDF =================
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf, color: Colors.red),

                  title: const Text("رفع ملف الجلسة (PDF)"),

                  trailing: const Icon(Icons.upload_file),

                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("جاري فتح مدير الملفات لاختيار PDF..."),
                      ),
                    );
                  },
                ),

                // ================= VIDEO =================
                ListTile(
                  leading: const Icon(
                    Icons.video_collection,
                    color: Colors.green,
                  ),

                  title: const Text("رفع فيديو الجلسة (MP4)"),

                  trailing: const Icon(Icons.video_call),

                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("جاري اختيار الفيديو...")),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
