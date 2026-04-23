import 'package:flutter/material.dart';
import 'add_program_step2.dart';

class AddProgramStep1 extends StatefulWidget {
  const AddProgramStep1({super.key});

  @override
  State<AddProgramStep1> createState() => _AddProgramStep1State();
}

class _AddProgramStep1State extends State<AddProgramStep1> {
  final Set<int> selectedIndices = {};
  final specialists = [
    {'name': 'أ. أحمد محمد', 'job': 'أخصائي تخاطب'},
    {'name': 'أ. سارة علي', 'job': 'أخصائي نفسي'},
    {'name': 'أ. محمود عبدالله', 'job': 'أخصائي علاج طبيعي'},
    {'name': 'أ. نهى يوسف', 'job': 'تنمية مهارات'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اختيار الأخصائيين')),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: specialists.length,
                itemBuilder: (context, index) {
                  final isSelected = selectedIndices.contains(index);
                  return CheckboxListTile(
                    title: Text(specialists[index]['name']!),
                    subtitle: Text(specialists[index]['job']!),
                    value: isSelected,
                    onChanged: (val) {
                      setState(() {
                        if (val!) {
                          selectedIndices.add(index);
                        } else {
                          selectedIndices.remove(index);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5484A4),
                  ),
                  onPressed: selectedIndices.isEmpty
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddProgramStep2(),
                            ),
                          );
                        },
                  child: Text(
                    'التالي (${selectedIndices.length})',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
