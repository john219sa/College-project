import 'package:flutter/material.dart';
import 'add_program_step1.dart';

class FamiliesScreen extends StatelessWidget {
  const FamiliesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الأسر'), centerTitle: true),

      body: Column(
        children: [
          /// 🔹 كارت الأسرة
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('أسرة ضعيف', style: TextStyle(fontSize: 18)),
                Icon(Icons.groups, size: 30),
              ],
            ),
          ),

          /// 🔹 Tabs (مبدئي)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              Text('الأخصائيين'),
              Text('الحالات'),
              Text('معلومات الأسرة'),
            ],
          ),

          const SizedBox(height: 10),

          /// 🔹 قائمة الأخصائيين (مؤقتة)
          Expanded(
            child: ListView(
              children: const [
                ListTile(
                  leading: CircleAvatar(),
                  title: Text('أ. أحمد محمد'),
                  subtitle: Text('أخصائي تخاطب'),
                ),
                ListTile(
                  leading: CircleAvatar(),
                  title: Text('أ. سارة علي'),
                  subtitle: Text('أخصائي نفسي'),
                ),
              ],
            ),
          ),
        ],
      ),

      /// 🔹 زر إضافة منهج
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProgramStep1()),
          );
        },
        label: const Text('إضافة منهج'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
