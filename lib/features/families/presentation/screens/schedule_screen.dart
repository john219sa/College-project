import 'package:flutter/material.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int selectedDayIndex = 0;

  // قاعدة بيانات تجريبية للمواعيد
  List<Map<String, dynamic>> allSessions = [
    {
      'dayIndex': 0,
      'time': '09:00 AM',
      'hour': 9,
      'minute': 0,
      'child': 'أحمد محمد',
      'service': 'تخاطب',
      'room': 'قاعة 1',
      'status': 'تمت',
    },
    {
      'dayIndex': 0,
      'time': '11:30 AM',
      'hour': 11,
      'minute': 30,
      'child': 'سارة محمود',
      'service': 'تكامل حسي',
      'room': 'قاعة 3',
      'status': 'انتظار',
    },
  ];

  // متغيرات مؤقتة للإضافة
  String? tempChild;
  String? tempService;
  String? tempRoom;
  TimeOfDay tempTime = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    final displayedSessions = allSessions
        .where((s) => s['dayIndex'] == selectedDayIndex)
        .toList();
    int total = displayedSessions.length;
    int completed = displayedSessions.where((s) => s['status'] == 'تمت').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text(
          'جدول الجلسات',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildDateBar(),
          _buildDailySummary(total, completed),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'مواعيد اليوم',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: displayedSessions.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: displayedSessions.length,
                    itemBuilder: (context, index) =>
                        _buildScheduleCard(displayedSessions[index]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSessionSheet(context),
        label: const Text('إضافة موعد'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  // نافذة الإضافة (نفس الصفحة)
  void _showAddSessionSheet(BuildContext context) {
    tempChild = null;
    tempService = null;
    tempRoom = null;
    tempTime = TimeOfDay.now();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'حجز جلسة جديدة',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  _buildSimpleDropdown('الاخصائي', [
                    'أحمد محمد',
                    'سارة محمود',
                    'ياسين علي',
                  ], (v) => tempChild = v),
                  const SizedBox(height: 15),
                  _buildSimpleDropdown('نوع الجلسة', [
                    'اختبارات ذكاء',
                    'جلسات تكامل حسي',
                    ' تخاطب',
                    'تنمية مهارات',
                    'تخاطب',
                    'تعديل سلوك',
                    'أكاديمي',
                  ], (v) => tempService = v),
                  const SizedBox(height: 15),
                  _buildSimpleDropdown('القاعة', [
                    'قاعة 1',
                    'قاعة 2',
                    'قاعة 3',
                  ], (v) => tempRoom = v),
                  const SizedBox(height: 15),
                  ListTile(
                    tileColor: Colors.grey[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    title: Text("الوقت: ${tempTime.format(context)}"),
                    trailing: const Icon(
                      Icons.access_time,
                      color: Colors.blueAccent,
                    ),
                    onTap: () async {
                      TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: tempTime,
                      );
                      if (picked != null)
                        setSheetState(() => tempTime = picked);
                    },
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () => _handleSave(context),
                      child: const Text(
                        'حفظ',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _handleSave(BuildContext context) {
    if (tempChild == null || tempService == null || tempRoom == null) return;

    // فحص التعارض
    bool conflict = allSessions.any(
      (s) =>
          s['dayIndex'] == selectedDayIndex &&
          s['room'] == tempRoom &&
          s['hour'] == tempTime.hour &&
          s['minute'] == tempTime.minute,
    );

    if (conflict) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('تعارض'),
          content: const Text('القاعة مشغولة في هذا الوقت'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('حسناً'),
            ),
          ],
        ),
      );
    } else {
      setState(() {
        allSessions.add({
          'dayIndex': selectedDayIndex,
          'time': tempTime.format(context),
          'hour': tempTime.hour,
          'minute': tempTime.minute,
          'child': tempChild,
          'service': tempService,
          'room': tempRoom,
          'status': 'انتظار',
        });
      });
      Navigator.pop(context);
    }
  }

  // ودجت الـ Dropdown بدون الخصائص المسببة للمشاكل
  Widget _buildSimpleDropdown(
    String hint,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
      isExpanded: true,
      items: items
          .map(
            (e) => DropdownMenuItem(
              value: e,
              child: Align(alignment: Alignment.centerRight, child: Text(e)),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDailySummary(int total, int completed) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('$total', 'الكل', Colors.blue),
          _buildStatItem('$completed', 'تمت', Colors.green),
          _buildStatItem('${total - completed}', 'متبقي', Colors.orange),
        ],
      ),
    );
  }

  Widget _buildStatItem(String val, String label, Color col) {
    return Column(
      children: [
        Text(
          val,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: col,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildScheduleCard(Map<String, dynamic> item) {
    bool done = item['status'] == 'تمت';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle : Icons.radio_button_unchecked,
            color: done ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item['child'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: done ? TextDecoration.lineThrough : null,
                  ),
                ),
                Text(
                  '${item['service']} - ${item['room']}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(width: 15),
          Text(
            item['time'],
            style: const TextStyle(
              color: Colors.blueAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateBar() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        reverse: true,
        itemCount: 7,
        itemBuilder: (context, index) {
          bool isSelected = selectedDayIndex == index;
          return GestureDetector(
            onTap: () => setState(() => selectedDayIndex = index),
            child: Container(
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blueAccent : Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'مايو',
                    style: TextStyle(
                      color: isSelected ? Colors.white70 : Colors.grey,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    '${14 + index}',
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
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

  Widget _buildEmptyState() => const Center(child: Text('لا توجد جلسات'));
}
