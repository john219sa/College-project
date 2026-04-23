import 'package:flutter/material.dart';

class TeamManagementScreen extends StatelessWidget {
  const TeamManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الفريق'),
        backgroundColor: const Color(0xFF5484A4),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildStaffTile('م. مينا فوزي', 'رئيس أسرة'),
            _buildStaffTile('أ. رانيا علي', 'مساعد إداري'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF5484A4),
        onPressed: () => _showAddStaffDialog(context),
        label: const Text(
          'إضافة عضو جديد',
          style: TextStyle(color: Colors.white),
        ),
        icon: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }

  Widget _buildStaffTile(String name, String role) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person)),
        title: Text(name),
        subtitle: Text(role),
        trailing: const Icon(Icons.edit, size: 20),
      ),
    );
  }

  void _showAddStaffDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'إضافة عضو جديد',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'الاسم',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField(
                items: const [
                  DropdownMenuItem(value: '1', child: Text('رئيس أسرة')),
                  DropdownMenuItem(value: '2', child: Text('مساعد')),
                ],
                onChanged: (v) {},
                decoration: const InputDecoration(
                  labelText: 'المنصب',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5484A4),
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('حفظ', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
