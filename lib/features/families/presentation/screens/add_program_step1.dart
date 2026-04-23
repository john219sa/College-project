import 'package:flutter/material.dart';

class AddProgramStep1 extends StatefulWidget {
  const AddProgramStep1({super.key});

  @override
  State<AddProgramStep1> createState() => _AddProgramStep1State();
}

class _AddProgramStep1State extends State<AddProgramStep1> {
  int selectedIndex = -1;

  final specialists = [
    {'name': 'أ. أحمد محمد', 'job': 'أخصائي تخاطب'},
    {'name': 'أ. سارة علي', 'job': 'أخصائي نفسي'},
    {'name': 'أ. محمود عبدالله', 'job': 'أخصائي علاج طبيعي'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اختيار الأخصائي')),

      body: Column(
        children: [
          const SizedBox(height: 10),

          /// 🔹 قائمة الأخصائيين
          Expanded(
            child: ListView.builder(
              itemCount: specialists.length,
              itemBuilder: (context, index) {
                final item = specialists[index];
                final isSelected = selectedIndex == index;

                return Card(
                  margin: const EdgeInsets.all(10),
                  color: isSelected ? Colors.green.shade100 : null,
                  child: ListTile(
                    leading: const CircleAvatar(),
                    title: Text(item['name']!),
                    subtitle: Text(item['job']!),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : null,
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                  ),
                );
              },
            ),
          ),

          /// 🔹 زر التالي
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: selectedIndex == -1
                  ? null
                  : () {
                      // هنكمل بعدين
                    },
              child: const Text('التالي'),
            ),
          ),
        ],
      ),
    );
  }
}
