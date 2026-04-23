import 'package:flutter/material.dart';
import 'add_program_step1.dart';

class FamiliesScreen extends StatelessWidget {
  const FamiliesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'إدارة الأسرة',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // هيدر تعريفي بالأسرة
            _buildFamilyHeader(),

            // منطقة الأعمدة الثلاثة
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // العمود الأول: الأخصائيين
                    _buildDataColumn(
                      title: 'الأخصائيين',
                      icon: Icons.psychology,
                      color: Colors.blue.shade700,
                      items: ['أ. أحمد محمد', 'أ. سارة علي', 'أ. محمود جابر'],
                    ),
                    const SizedBox(width: 8),
                    // العمود الثاني: الحالات
                    _buildDataColumn(
                      title: 'الحالات',
                      icon: Icons.child_care,
                      color: Colors.orange.shade700,
                      items: [
                        'يوسف علي',
                        'مريم إبراهيم',
                        'فهد محمود',
                        'ليلى حسن',
                      ],
                    ),
                    const SizedBox(width: 8),
                    // العمود الثالث: الملاحظات
                    _buildDataColumn(
                      title: 'الملاحظات',
                      icon: Icons.edit_note,
                      color: Colors.green.shade700,
                      items: [
                        'تطور ملحوظ',
                        'يحتاج متابعة',
                        'تأخر في الجلسة',
                        'تم الإنجاز',
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // زر إضافة المنهج في الأسفل
            _buildAddBottomButton(context),
          ],
        ),
      ),
    );
  }

  // ويدجت الهيدر
  Widget _buildFamilyHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5484A4), Color(0xFF7BA8C7)],
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'أسرة الحالات الشديدة',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'المسؤول: م. مينا فوزي',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ويدجت بناء العمود الواحد
  Widget _buildDataColumn({
    required String title,
    required IconData icon,
    required Color color,
    required List<String> items,
  }) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5),
          ],
        ),
        child: Column(
          children: [
            // رأس العمود
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 18, color: color),
                  const SizedBox(width: 5),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            // قائمة العناصر داخل العمود
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(8),
                itemCount: items.length,
                separatorBuilder: (context, index) => const Divider(height: 15),
                itemBuilder: (context, index) {
                  return Text(
                    items[index],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // الزر السفلي
  Widget _buildAddBottomButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5484A4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddProgramStep1()),
            );
          },
          icon: const Icon(Icons.add_circle_outline, color: Colors.white),
          label: const Text(
            'إضافة منهاج جديد للأسرة',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
