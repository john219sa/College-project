import 'package:flutter/material.dart';

class TherapistsScreen extends StatefulWidget {
  const TherapistsScreen({super.key});

  @override
  State<TherapistsScreen> createState() => _TherapistsScreenState();
}

class _TherapistsScreenState extends State<TherapistsScreen> {
  // قائمة تجريبية للأخصائيين (سيتم جلبها لاحقاً من الـ MySQL)
  final List<Map<String, dynamic>> _therapists = [
    {
      "name": "د. أحمد كمال",
      "specialty": "تخاطب وعيوب نطق",
      "isAvailable": true,
    },
    {
      "name": "أ. سارة ممدوح",
      "specialty": "تعديل سلوك وصعوبات تعلم",
      "isAvailable": false,
    },
    {
      "name": "د. مينا نصحي",
      "specialty": "تنمية مهارات وإرشاد أسري",
      "isAvailable": true,
    },
  ];

  // دالة لإظهار فورم إضافة أخصائي جديد
  void _showAddTherapistDialog() {
    final nameController = TextEditingController();
    String selectedSpecialty = 'تخاطب';
    List<String> availableDays = [];

    // قائمة الأيام لاختيار المتاح منها
    final daysOfWeek = [
      'السبت',
      'الأحد',
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          // استخدام StatefulBuilder لتحديث الاختيارات داخل الـ Dialog
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'إضافة أخصائي جديد',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // حقل الاسم
                    const Text(
                      'اسم الأخصائي',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextField(
                      controller: nameController,
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        hintText: 'أدخل الاسم ثنائياً أو ثلاثياً',
                        prefixIcon: const Icon(
                          Icons.person_outline,
                          color: Color(0xFF2575FC),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // اختيار التخصص
                    const Text(
                      'التخصص الأساسي',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 5),
                    DropdownButtonFormField<String>(
                      value: selectedSpecialty,
                      alignment: Alignment.centerRight,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: ['تخاطب', 'تعديل سلوك', 'تنمية مهارات'].map((val) {
                        return DropdownMenuItem(
                          value: val,
                          child: Text(val, textDirection: TextDirection.rtl),
                        );
                      }).toList(),
                      onChanged: (val) =>
                          setDialogState(() => selectedSpecialty = val!),
                    ),
                    const SizedBox(height: 15),
                    // اختيار الأيام المتاحة للعمل
                    const Text(
                      'أيام التواجد المتاحة',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      direction: Axis.horizontal,
                      textDirection: TextDirection.rtl,
                      children: daysOfWeek.map((day) {
                        final isSelected = availableDays.contains(day);
                        return FilterChip(
                          label: Text(
                            day,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: const Color(0xFF6A11CB),
                          checkmarkColor: Colors.white,
                          onSelected: (selected) {
                            setDialogState(() {
                              if (selected) {
                                availableDays.add(day);
                              } else {
                                availableDays.remove(day);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actionsAlignment: MainAxisAlignment.start,
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'إلغاء',
                    style: TextStyle(color: Colors.grey, fontFamily: 'Cairo'),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2575FC),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    if (nameController.text.isNotEmpty) {
                      setState(() {
                        // إضافة الأخصائي محلياً في القائمة (وهنا هيتم استدعاء الـ API الخاص بالـ MySQL لاحقاً)
                        _therapists.add({
                          "name": nameController.text,
                          "specialty": selectedSpecialty,
                          "isAvailable": true,
                        });
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'تم حفظ الأخصائي الجديد بنجاح بنظام MySQL',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'حفظ البيانات',
                    style: TextStyle(fontFamily: 'Cairo', color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        title: const Text(
          'إدارة الأخصائيين',
          style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black87,
      ),

      // زر الحجز العائم لإضافة أخصائي جديد
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTherapistDialog,
        backgroundColor: const Color(0xFF2575FC),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'إضافة أخصائي',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation
          .startFloat, // تموضعه لليسار ليناسب واجهات العربي
      body: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: _therapists.length,
        itemBuilder: (context, index) {
          final therapist = _therapists[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // ١. حالة النشاط (متاح / في جلسة) جهة اليسار
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: therapist['isAvailable']
                              ? Colors.green.withOpacity(0.1)
                              : Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          therapist['isAvailable'] ? 'متاح حالياً' : 'في جلسة',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: therapist['isAvailable']
                                ? Colors.green
                                : Colors.amber.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // ٢. تفاصيل الأخصائي (الاسم والتخصص) في المنتصف
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        therapist['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        therapist['specialty'],
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 15),

                  // ٣. صورة الأخصائي الافتراضية جهة اليمين
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xFF6A11CB).withOpacity(0.1),
                    child: const Icon(
                      Icons.person,
                      size: 30,
                      color: Color(0xFF6A11CB),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
