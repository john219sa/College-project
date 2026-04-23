import 'package:flutter/material.dart';

class AddProgramStep2 extends StatefulWidget {
  const AddProgramStep2({super.key});

  @override
  State<AddProgramStep2> createState() => _AddProgramStep2State();
}

class _AddProgramStep2State extends State<AddProgramStep2> {
  // المتحكمات في النصوص
  final _programNameController = TextEditingController();
  final _treatmentPlanController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        title: const Text('إعداد محتوى المنهج'),
        backgroundColor: const Color(0xFF5484A4),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // حقل اسم المنهج الأساسي
              const Text(
                'اسم المنهج العام:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _programNameController,
                decoration: const InputDecoration(
                  hintText: 'مثلاً: منهج التخاطب الشامل - ليفل 1',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 25),

              // 1. قسم الخطة العلاجية
              _buildSectionHeader('1. الخطة العلاجية (نصي)', Icons.edit_note),
              TextField(
                controller: _treatmentPlanController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'اكتب تفاصيل التدخل العلاجي هنا...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // 2. قسم التقارير (PDF)
              _buildSectionHeader(
                '2. رفع تقارير المتابعة (PDF)',
                Icons.upload_file,
              ),
              _buildAddButton(
                'إضافة ملف PDF جديد',
                Colors.red,
                Icons.picture_as_pdf,
              ),

              const SizedBox(height: 20),

              // 3. قسم التمارين المصورة
              _buildSectionHeader(
                '3. التمارين المصورة (صور)',
                Icons.image_search,
              ),
              _buildAddButton(
                'رفع صور التمارين',
                Colors.blue,
                Icons.add_a_photo,
              ),

              const SizedBox(height: 20),

              // 4. قسم تمارين الفيديو
              _buildSectionHeader(
                '4. فيديوهات التمارين (فيديو)',
                Icons.video_library,
              ),
              _buildAddButton(
                'رفع فيديو تدريبي',
                Colors.orange,
                Icons.video_call,
              ),

              const SizedBox(height: 20),

              // 5. قسم الواجبات المنزلية
              _buildSectionHeader(
                '5. الواجبات المنزلية اليومية',
                Icons.assignment_turned_in,
              ),
              _buildAddButton(
                'إضافة واجب جديد لولي الأمر',
                Colors.green,
                Icons.add_task,
              ),

              const SizedBox(height: 40),

              // زر الحفظ النهائي للبرنامج بالكامل
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5484A4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // هنا سيتم تنفيذ كود الحفظ في قاعدة البيانات لاحقاً
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم حفظ المنهج بالكامل بنجاح'),
                      ),
                    );
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text(
                    'إنشاء المنهج وحفظ البيانات',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ويدجت عنوان القسم
  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF5484A4)),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ويدجت زر الإضافة لكل قسم
  Widget _buildAddButton(String label, Color color, IconData icon) {
    return InkWell(
      onTap: () {
        // هنا سيتم استدعاء Picker لكل نوع (File, Image, Video)
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
