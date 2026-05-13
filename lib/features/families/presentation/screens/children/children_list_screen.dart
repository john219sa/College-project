import 'package:flutter/material.dart';
import '../psychologists/psychologist_screen.dart';
// إضافة استيراد صفحة تفاصيل الطفل
import 'child_details_screen.dart';

class ChildrenListScreen extends StatelessWidget {
  const ChildrenListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),

      appBar: AppBar(
        title: const Text('أسرة الحالات الشديدة'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      body: Column(
        children: [
          // ================= SPECIALISTS SECTION =================
          Container(
            width: double.infinity,

            margin: const EdgeInsets.all(15),

            padding: const EdgeInsets.all(20),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,

              children: [
                const Text(
                  'الأخصائيين المسؤولين',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.blueAccent,
                  ),
                ),

                const SizedBox(height: 15),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    // ================= SPEECH SPECIALIST =================
                    _buildSpecialistButton(
                      context,
                      'أخصائي تخاطب',
                      Icons.record_voice_over,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'سيتم إضافة صفحة أخصائي التخاطب قريباً',
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(width: 20),

                    // ================= PSYCHOLOGIST =================
                    _buildSpecialistButton(
                      context,
                      'أخصائي نفسي',
                      Icons.psychology,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PsychologistScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ================= SEARCH FIELD =================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),

            child: TextField(
              textAlign: TextAlign.right,

              decoration: InputDecoration(
                hintText: 'ابحث عن اسم الطفل...',

                prefixIcon: const Icon(Icons.search),

                filled: true,
                fillColor: Colors.white,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ================= CHILDREN LIST =================
          Expanded(
            child: ListView.builder(
              itemCount: 10,

              itemBuilder: (context, index) {
                final String childName = 'الطفل: حالة شديدة ${index + 1}';

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 5,
                  ),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),

                  elevation: 1,

                  child: ListTile(
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),

                    leading: CircleAvatar(
                      backgroundColor: Colors.redAccent.withOpacity(0.1),

                      child: const Icon(
                        Icons.child_care,
                        color: Colors.redAccent,
                      ),
                    ),

                    title: Text(
                      childName,
                      textAlign: TextAlign.right,

                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    subtitle: const Text(
                      'اضغط لعرض تفاصيل الحالة',
                      textAlign: TextAlign.right,
                    ),

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ChildDetailsScreen(childName: childName),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // ================= FLOATING BUTTON =================
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddChildSheet(context);
        },

        label: const Text('إضافة طفل جديد'),

        icon: const Icon(Icons.add),

        backgroundColor: Colors.redAccent,
      ),
    );
  }

  // ================= SPECIALIST BUTTON =================

  Widget _buildSpecialistButton(
    BuildContext context,
    String label,
    IconData icon, {
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,

      borderRadius: BorderRadius.circular(15),

      child: Column(
        children: [
          CircleAvatar(
            radius: 25,

            backgroundColor: Colors.blue.withOpacity(0.1),

            child: Icon(icon, color: Colors.blueAccent),
          ),

          const SizedBox(height: 5),

          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // ================= ADD CHILD SHEET =================

  void _showAddChildSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,

      isScrollControlled: true,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),

      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),

          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                const Text(
                  'إضافة بيانات طفل جديد',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                // ================= CHILD NAME =================
                TextField(
                  textAlign: TextAlign.right,

                  decoration: InputDecoration(
                    hintText: 'اسم الطفل',

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // ================= AGE =================
                TextField(
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.right,

                  decoration: InputDecoration(
                    hintText: 'العمر',

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // ================= NOTES =================
                TextField(
                  maxLines: 3,
                  textAlign: TextAlign.right,

                  decoration: InputDecoration(
                    hintText: 'ملاحظات الحالة',

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ================= SAVE BUTTON =================
                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),

                    child: const Text('حفظ البيانات'),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
