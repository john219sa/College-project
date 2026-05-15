import 'package:flutter/material.dart';

class WaitingListScreen extends StatefulWidget {
  const WaitingListScreen({super.key});
  @override
  State<WaitingListScreen> createState() => _WaitingListScreenState();
}

class _WaitingListScreenState extends State<WaitingListScreen> {
  final List<Map<String, dynamic>> _allCases = [
    {
      'name': 'أحمد محمد علي',
      'type': 'تخاطب',
      'priority': 'عالية',
      'date': '2026/05/10',
      'age': '7 سنوات',
    },
    {
      'name': 'سارة محمود',
      'type': 'تنمية مهارات',
      'priority': 'متوسطة',
      'date': '2026/05/12',
      'age': '5 سنوات',
    },
    {
      'name': 'ياسين كريم',
      'type': 'جلسات تكامل حسي',
      'priority': 'عالية',
      'date': '2026/05/13',
      'age': '8 سنوات',
    },
    {
      'name': 'ليلى يوسف',
      'type': 'أكاديمي',
      'priority': 'عادية',
      'date': '2026/05/14',
      'age': '6 سنوات',
    },
  ];

  String _selectedFilter = 'الكل';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        title: const Text(
          'قائمة الانتظار',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const TextField(
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: 'ابحث عن اسم الطفل...',
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 20,
                  ),
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children:
                  [
                    'الكل',
                    'تخاطب',
                    'تعديل سلوك',
                    'اختبار ذكاء',
                    'تنمية مهارات',
                    'أكاديمي',
                    'جلسات تكامل حسي',
                  ].map((filter) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: FilterChip(
                        label: Text(filter),
                        selected: _selectedFilter == filter,
                        onSelected: (selected) =>
                            setState(() => _selectedFilter = filter),
                        shape: const StadiumBorder(),
                      ),
                    );
                  }).toList(),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: _allCases
                  .where(
                    (c) =>
                        _selectedFilter == 'الكل' ||
                        c['type'] == _selectedFilter,
                  )
                  .length,
              padding: const EdgeInsets.all(15),
              itemBuilder: (context, index) {
                final filteredList = _allCases
                    .where(
                      (c) =>
                          _selectedFilter == 'الكل' ||
                          c['type'] == _selectedFilter,
                    )
                    .toList();
                final item = filteredList[index];

                Color priorityColor = item['priority'] == 'عالية'
                    ? Colors.red
                    : (item['priority'] == 'متوسطة'
                          ? Colors.orange
                          : Colors.green);
                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: priorityColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        item['priority'],
                        style: TextStyle(
                          color: priorityColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      item['name'],
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'التخصص: ${item['type']}',
                      textAlign: TextAlign.right,
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                StudentDetailScreen(studentData: item),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2575FC),
                        shape: const StadiumBorder(),
                        elevation: 0,
                      ),
                      child: const Text(
                        'عرض الحالة',
                        style: TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// --- هذه هي الصفحة التي كانت تسبب الخطأ، أضفتها لكِ هنا في نفس الملف ---
class StudentDetailScreen extends StatelessWidget {
  final Map<String, dynamic> studentData;

  const StudentDetailScreen({super.key, required this.studentData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل الطالب'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Center(
              child: Icon(
                Icons.account_circle,
                size: 100,
                color: Color(0xFF2575FC),
              ),
            ),
            const SizedBox(height: 20),
            _infoTile('الاسم الكامل', studentData['name']),
            _infoTile('العمر', studentData['age']),
            _infoTile('التخصص المختار', studentData['type']),
            _infoTile('حالة الأولوية', studentData['priority']),
            _infoTile('تاريخ التسجيل', studentData['date']),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  padding: const EdgeInsets.all(15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'الرجوع للقائمة',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text('$title :', style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
