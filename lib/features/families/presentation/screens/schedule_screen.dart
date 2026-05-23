import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../../core/constants/api_constants.dart';

class ScheduleScreen extends StatefulWidget {
  final int specialistId;
  const ScheduleScreen({super.key, required this.specialistId});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  List<Map<String, dynamic>> _sessions = [];
  List<Map<String, dynamic>> _allSpecialists = [];
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();
  int _total = 0, _done = 0, _pending = 0;

  // ── شريط الأيام ─────────────────────────────────────────────
  // نبدأ من اليوم (index = 0) ونسمح بالتنقل ±365 يوم
  final int _dayRange = 365;
  late final ScrollController _dateScrollController;
  static const double _dayItemWidth = 63.0; // عرض كل يوم

  // ── متغيرات Bottom Sheet ─────────────────────────────────────
  // ✅ FIX 1: Set بدل List عشان نتجنب التكرار ونتحقق بسهولة
  Set<int> _selectedSpecialistIds = {};
  Map<int, List<Map<String, dynamic>>> _specialistChildren = {};
  Map<int, List<int>> _selectedChildrenPerSpecialist = {};
  Map<int, bool> _selectAllPerSpecialist = {};
  TimeOfDay _selectedTime = TimeOfDay.now();
  DateTime _newSessionDate = DateTime.now();
  String _selectedType = 'تخاطب';
  String _selectedRoom = 'قاعة 1';

  final List<String> _sessionTypes = [
    'تخاطب',
    'تكامل حسي',
    'تعديل سلوك',
    'أكاديمي',
    'تنمية مهارات',
    'اختبار ذكاء',
  ];
  final List<String> _rooms = ['قاعة 1', 'قاعة 2', 'قاعة 3', 'قاعة 4'];

  // ════════════════════════════════════════════════════════════
  @override
  void initState() {
    super.initState();
    _dateScrollController = ScrollController();
    _fetchSessions();
    _fetchAllSpecialists();

    // ✅ FIX 2: بعد البناء مباشرة، اسكرول على اليوم (index = _dayRange)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToToday(animate: false);
    });
  }

  @override
  void dispose() {
    _dateScrollController.dispose();
    super.dispose();
  }

  // ── scroll على اليوم ─────────────────────────────────────────
  void _scrollToToday({bool animate = true}) {
    final offset = _dayRange * _dayItemWidth;
    if (!_dateScrollController.hasClients) return;
    if (animate) {
      _dateScrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _dateScrollController.jumpTo(offset);
    }
  }

  // ── تنسيق التاريخ ────────────────────────────────────────────
  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  bool _isToday(DateTime d) => _formatDate(d) == _formatDate(DateTime.now());

  // ════════════════════════════════════════════════════════════
  // API
  // ════════════════════════════════════════════════════════════

  Future<void> _fetchSessions() async {
    setState(() => _isLoading = true);
    try {
      final url = widget.specialistId == 0
          ? '${ApiConstants.baseUrl}/sessions/get_sessions.php'
                '?date=${_formatDate(_selectedDate)}'
          : '${ApiConstants.baseUrl}/sessions/get_sessions.php'
                '?specialist_id=${widget.specialistId}'
                '&date=${_formatDate(_selectedDate)}';

      final res = await http.get(Uri.parse(url));
      final data = jsonDecode(res.body);
      if (data['status'] == true) {
        setState(() {
          _sessions = List<Map<String, dynamic>>.from(data['data']);
          _total = data['stats']?['total'] ?? _sessions.length;
          _done =
              data['stats']?['done'] ??
              _sessions.where((s) => s['status'] == 'done').length;
          _pending =
              data['stats']?['pending'] ??
              _sessions.where((s) => s['status'] == 'pending').length;
        });
      }
    } catch (e) {
      debugPrint('fetchSessions: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchAllSpecialists() async {
    try {
      final res = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}/specialists/get_all_specialists.php',
        ),
      );
      final data = jsonDecode(res.body);
      if (data['status'] == true) {
        setState(
          () => _allSpecialists = List<Map<String, dynamic>>.from(data['data']),
        );
      }
    } catch (e) {
      debugPrint('fetchSpecialists: $e');
    }
  }

  Future<void> _fetchChildrenForSpecialist(int spId) async {
    if (_specialistChildren.containsKey(spId)) return;
    try {
      final res = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}/children/get_specialist_children.php'
          '?specialist_id=$spId',
        ),
      );
      final data = jsonDecode(res.body);
      if (data['status'] == true) {
        if (mounted)
          setState(() {
            _specialistChildren[spId] = List<Map<String, dynamic>>.from(
              data['data'],
            );
            _selectedChildrenPerSpecialist[spId] = [];
            _selectAllPerSpecialist[spId] = false;
          });
      }
    } catch (e) {
      debugPrint('fetchChildren: $e');
    }
  }

  Future<void> _toggleStatus(int sessionId, String currentStatus) async {
    final newStatus = currentStatus == 'done' ? 'pending' : 'done';
    try {
      await http.post(
        Uri.parse('${ApiConstants.baseUrl}/sessions/update_session_status.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'session_id': sessionId, 'status': newStatus}),
      );
      _fetchSessions();
    } catch (e) {
      debugPrint('toggleStatus: $e');
    }
  }

  Future<void> _saveSession() async {
    if (_selectedSpecialistIds.isEmpty) {
      _showSnack('اختر أخصائي واحد على الأقل', Colors.orange);
      return;
    }
    bool hasChildren = _selectedSpecialistIds.any(
      (spId) => (_selectedChildrenPerSpecialist[spId] ?? []).isNotEmpty,
    );
    if (!hasChildren) {
      _showSnack('اختر طفل واحد على الأقل', Colors.orange);
      return;
    }

    final timeStr =
        '${_selectedTime.hour.toString().padLeft(2, '0')}:'
        '${_selectedTime.minute.toString().padLeft(2, '0')}:00';

    bool allSuccess = true;
    for (final spId in _selectedSpecialistIds) {
      final childIds = _selectedChildrenPerSpecialist[spId] ?? [];
      if (childIds.isEmpty) continue;
      try {
        final res = await http.post(
          Uri.parse('${ApiConstants.baseUrl}/sessions/add_session.php'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'specialist_id': spId,
            'child_ids': childIds,
            'session_date': _formatDate(_newSessionDate),
            'session_time': timeStr,
            'location': _selectedRoom,
            'session_type': _selectedType,
            'notes': '',
            'created_by': 1, // admin id
          }),
        );
        final data = jsonDecode(res.body);
        if (data['status'] != true) allSuccess = false;
      } catch (_) {
        allSuccess = false;
      }
    }

    _showSnack(
      allSuccess ? 'تم حفظ الجلسات بنجاح' : 'حدث خطأ في بعض الجلسات',
      allSuccess ? Colors.green : Colors.red,
    );
    if (allSuccess) _fetchSessions();
  }

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  // ════════════════════════════════════════════════════════════
  // BOTTOM SHEET
  // ════════════════════════════════════════════════════════════

  void _showAddSheet() {
    // ✅ Reset كل حاجة عند الفتح
    _selectedSpecialistIds = {};
    _specialistChildren = {};
    _selectedChildrenPerSpecialist = {};
    _selectAllPerSpecialist = {};
    _selectedTime = TimeOfDay.now();
    _newSessionDate = _selectedDate;
    _selectedType = _sessionTypes.first;
    _selectedRoom = _rooms.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.92,
          maxChildSize: 0.97,
          builder: (_, sc) => SingleChildScrollView(
            controller: sc,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'حجز جلسة جديدة',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Divider(height: 25),

                // ── نوع الجلسة ─────────────────────────────
                _sectionLabel('نوع الجلسة'),
                const SizedBox(height: 8),
                _dropdown(
                  value: _selectedType,
                  items: _sessionTypes,
                  onChanged: (v) => setModal(() => _selectedType = v!),
                ),
                const SizedBox(height: 15),

                // ── القاعة ─────────────────────────────────
                _sectionLabel('القاعة'),
                const SizedBox(height: 8),
                _dropdown(
                  value: _selectedRoom,
                  items: _rooms,
                  onChanged: (v) => setModal(() => _selectedRoom = v!),
                ),
                const SizedBox(height: 15),

                // ── التاريخ والوقت ─────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today, size: 16),
                        label: Text(
                          _formatDate(_newSessionDate),
                          style: const TextStyle(fontSize: 13),
                        ),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate: _newSessionDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setModal(() => _newSessionDate = picked);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.access_time, size: 16),
                        label: Text(
                          _selectedTime.format(ctx),
                          style: const TextStyle(fontSize: 13),
                        ),
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: ctx,
                            initialTime: _selectedTime,
                          );
                          if (picked != null) {
                            setModal(() => _selectedTime = picked);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── اختيار الأخصائيين ──────────────────────
                _sectionLabel('اختر الأخصائيين'),
                const SizedBox(height: 8),

                _allSpecialists.isEmpty
                    ? const Center(
                        child: Text(
                          'لا يوجد أخصائيون',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : Column(
                        children: _allSpecialists.map((sp) {
                          final spId = int.parse(sp['id'].toString());

                          // ✅ FIX 1: كل أخصائي يتحدد بشكل مستقل
                          final isSpSelected = _selectedSpecialistIds.contains(
                            spId,
                          );

                          final spType = sp['specialist_type'] ?? '';
                          final spTypeAr = _spTypeLabel(spType);

                          return Column(
                            children: [
                              // صندوق الأخصائي
                              Container(
                                margin: const EdgeInsets.only(bottom: 4),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isSpSelected
                                        ? const Color(0xFF2575FC)
                                        : Colors.grey.shade200,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  color: isSpSelected
                                      ? const Color(
                                          0xFF2575FC,
                                        ).withValues(alpha: 0.05)
                                      : Colors.white,
                                ),
                                child: CheckboxListTile(
                                  title: Text(
                                    sp['full_name'] ?? '',
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${sp['family_name'] ?? ''} — $spTypeAr',
                                    textAlign: TextAlign.right,
                                  ),
                                  value: isSpSelected,
                                  activeColor: const Color(0xFF2575FC),
                                  // ✅ FIX 1: add/remove من الـ Set
                                  onChanged: (v) async {
                                    setModal(() {
                                      if (v == true) {
                                        _selectedSpecialistIds.add(spId);
                                      } else {
                                        _selectedSpecialistIds.remove(spId);
                                        _selectedChildrenPerSpecialist.remove(
                                          spId,
                                        );
                                      }
                                    });
                                    if (v == true) {
                                      await _fetchChildrenForSpecialist(spId);
                                      setModal(() {});
                                    }
                                  },
                                ),
                              ),

                              // أطفال الأخصائي لو مختار
                              if (isSpSelected)
                                Container(
                                  margin: const EdgeInsets.only(
                                    right: 16,
                                    left: 8,
                                    bottom: 8,
                                  ),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      // زرار اختيار الكل
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          TextButton(
                                            onPressed: () => setModal(() {
                                              final children =
                                                  _specialistChildren[spId] ??
                                                  [];
                                              final allSel =
                                                  _selectAllPerSpecialist[spId] ??
                                                  false;
                                              _selectAllPerSpecialist[spId] =
                                                  !allSel;
                                              _selectedChildrenPerSpecialist[spId] =
                                                  !allSel
                                                  ? children
                                                        .map(
                                                          (c) => int.parse(
                                                            c['id'].toString(),
                                                          ),
                                                        )
                                                        .toList()
                                                  : [];
                                            }),
                                            child: Text(
                                              (_selectAllPerSpecialist[spId] ??
                                                      false)
                                                  ? 'إلغاء الكل'
                                                  : 'اختيار الكل',
                                              style: const TextStyle(
                                                color: Color(0xFF2575FC),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            'أطفال ${sp['full_name'] ?? ''}:',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),

                                      // قائمة الأطفال
                                      _specialistChildren[spId] == null
                                          ? const Center(
                                              child: Padding(
                                                padding: EdgeInsets.all(8),
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                              ),
                                            )
                                          : _specialistChildren[spId]!.isEmpty
                                          ? const Padding(
                                              padding: EdgeInsets.all(8),
                                              child: Text(
                                                'لا يوجد أطفال مرتبطين',
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            )
                                          : Column(
                                              children: _specialistChildren[spId]!.map((
                                                child,
                                              ) {
                                                final cId = int.parse(
                                                  child['id'].toString(),
                                                );
                                                final isChildSel =
                                                    (_selectedChildrenPerSpecialist[spId] ??
                                                            [])
                                                        .contains(cId);
                                                return CheckboxListTile(
                                                  dense: true,
                                                  value: isChildSel,
                                                  activeColor: const Color(
                                                    0xFF2575FC,
                                                  ),
                                                  title: Text(
                                                    child['name'] ?? '',
                                                    textAlign: TextAlign.right,
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                  subtitle: Text(
                                                    'العمر: ${child['age']} — ${child['diagnosis'] ?? ''}',
                                                    textAlign: TextAlign.right,
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                  onChanged: (v) => setModal(() {
                                                    final list =
                                                        _selectedChildrenPerSpecialist[spId] ??
                                                        [];
                                                    v!
                                                        ? list.add(cId)
                                                        : list.remove(cId);
                                                    _selectedChildrenPerSpecialist[spId] =
                                                        list;
                                                    _selectAllPerSpecialist[spId] =
                                                        list.length ==
                                                        _specialistChildren[spId]!
                                                            .length;
                                                  }),
                                                );
                                              }).toList(),
                                            ),
                                    ],
                                  ),
                                ),
                            ],
                          );
                        }).toList(),
                      ),

                const SizedBox(height: 25),

                // زر الحفظ
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2575FC),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await _saveSession();
                    },
                    child: const Text(
                      'حفظ الجلسة',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
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
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchSessions,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSheet,
        backgroundColor: const Color(0xFF2575FC),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('إضافة موعد', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          _buildDateBar(),
          _buildSummary(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'مواعيد اليوم',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _sessions.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy, size: 60, color: Colors.grey),
                        SizedBox(height: 10),
                        Text(
                          'لا توجد جلسات في هذا اليوم',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _sessions.length,
                    itemBuilder: (_, i) => _buildSessionCard(_sessions[i]),
                  ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // DATE BAR — ✅ FIX 2
  // ════════════════════════════════════════════════════════════

  Widget _buildDateBar() {
    final today = DateTime.now();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: Column(
        children: [
          // ── شريط الأيام ─────────────────────────────────────
          Row(
            children: [
              // ← سهم لليوم السابق
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Color(0xFF2575FC)),
                onPressed: () {
                  setState(() {
                    _selectedDate = _selectedDate.subtract(
                      const Duration(days: 1),
                    );
                  });
                  _fetchSessions();
                },
              ),

              Expanded(
                child: SizedBox(
                  height: 70,
                  child: ListView.builder(
                    controller: _dateScrollController,
                    scrollDirection: Axis.horizontal,
                    // ✅ index 0 = اليوم - 365 ، index _dayRange = اليوم
                    itemCount: _dayRange * 2 + 1,
                    itemBuilder: (_, i) {
                      final day = today.subtract(Duration(days: _dayRange - i));
                      final isSelected =
                          _formatDate(day) == _formatDate(_selectedDate);
                      final todayDay = _isToday(day);

                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedDate = day);
                          _fetchSessions();
                        },
                        child: Container(
                          width: _dayItemWidth - 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF2575FC)
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(14),
                            border: todayDay && !isSelected
                                ? Border.all(
                                    color: const Color(0xFF2575FC),
                                    width: 1.5,
                                  )
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _monthName(day.month),
                                style: TextStyle(
                                  fontSize: 9,
                                  color: isSelected
                                      ? Colors.white70
                                      : Colors.grey,
                                ),
                              ),
                              Text(
                                '${day.day}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                              Text(
                                _dayName(day.weekday),
                                style: TextStyle(
                                  fontSize: 9,
                                  color: isSelected
                                      ? Colors.white70
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // سهم لليوم التالي →
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Color(0xFF2575FC)),
                onPressed: () {
                  setState(() {
                    _selectedDate = _selectedDate.add(const Duration(days: 1));
                  });
                  _fetchSessions();
                },
              ),
            ],
          ),

          // ✅ زرار "اليوم" للرجوع السريع
          TextButton.icon(
            onPressed: () {
              setState(() => _selectedDate = DateTime.now());
              _scrollToToday();
              _fetchSessions();
            },
            icon: const Icon(Icons.today, size: 16, color: Color(0xFF2575FC)),
            label: const Text(
              'اليوم',
              style: TextStyle(color: Color(0xFF2575FC), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // WIDGETS
  // ════════════════════════════════════════════════════════════

  Widget _buildSummary() {
    return Container(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _statItem('$_total', 'الكل', Colors.blue),
          _statItem('$_done', 'تمت', Colors.green),
          _statItem('$_pending', 'متبقي', Colors.orange),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // استبدل دالة _buildSessionCard الموجودة بالكود ده
  // واضيف دالة _showSessionDetails الجديدة
  // ════════════════════════════════════════════════════════════

  Widget _buildSessionCard(Map<String, dynamic> s) {
    final isDone = s['status'] == 'done';
    final isCancelled = s['status'] == 'cancelled';
    final timeStr = (s['session_time'] ?? '').toString();
    final displayTime = timeStr.length >= 5 ? timeStr.substring(0, 5) : timeStr;

    final children = s['children'] as List? ?? [];
    final childCount = children.length;
    final childNames = children
        .map((c) => c['name']?.toString() ?? '')
        .where((n) => n.isNotEmpty)
        .join(' / ');

    Color statusColor = isDone
        ? Colors.green
        : isCancelled
        ? Colors.red
        : const Color(0xFF2575FC);

    return GestureDetector(
      onTap: () => _showSessionDetails(s),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: statusColor.withOpacity(0.2), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            // ── زرار Toggle Done ──
            GestureDetector(
              onTap: isCancelled
                  ? null
                  : () => _toggleStatus(
                      int.parse(s['id'].toString()),
                      s['status'],
                    ),
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone ? Colors.green : Colors.white,
                  border: Border.all(
                    color: isDone ? Colors.green : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: isDone
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ),
            ),

            const SizedBox(width: 12),

            // ── تفاصيل الجلسة ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // نوع الجلسة
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        s['session_type'] ?? '',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isDone ? Colors.grey : Colors.black87,
                          decoration: isDone
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isDone
                              ? 'تمت'
                              : isCancelled
                              ? 'ملغاة'
                              : 'متبقي',
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // اسم الأخصائي
                  Text(
                    s['specialist_name'] ?? '',
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),

                  const SizedBox(height: 4),

                  // المكان + عدد الأطفال
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '$childCount طفل',
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.circle, size: 4, color: Colors.grey[400]),
                      const SizedBox(width: 8),
                      Text(
                        s['location'] ?? '',
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // ── الوقت + زرار إلغاء ──
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  displayTime,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 6),
                // ✅ زرار إلغاء الجلسة
                if (!isCancelled)
                  GestureDetector(
                    onTap: () => _confirmCancel(int.parse(s['id'].toString())),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: const Text(
                        'إلغاء',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // تفاصيل الجلسة عند الضغط
  // ════════════════════════════════════════════════════════════
  void _showSessionDetails(Map<String, dynamic> s) {
    final children = s['children'] as List? ?? [];
    final isDone = s['status'] == 'done';
    final isCancelled = s['status'] == 'cancelled';
    final timeStr = (s['session_time'] ?? '').toString();
    final displayTime = timeStr.length >= 5 ? timeStr.substring(0, 5) : timeStr;

    Color statusColor = isDone
        ? Colors.green
        : isCancelled
        ? Colors.red
        : const Color(0xFF2575FC);
    String statusLabel = isDone
        ? 'تمت'
        : isCancelled
        ? 'ملغاة'
        : 'متبقي';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.92,
        builder: (_, scroll) => SingleChildScrollView(
          controller: scroll,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Header ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Badge الحالة
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // عنوان
                  Text(
                    'تفاصيل الجلسة',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const Divider(height: 25),

              // ── بيانات الجلسة ──
              _detailTile(
                Icons.medical_services_rounded,
                Colors.purple,
                'الأخصائي',
                s['specialist_name'] ?? '',
              ),
              _detailTile(
                Icons.category_rounded,
                Colors.indigo,
                'نوع الجلسة',
                s['session_type'] ?? '',
              ),
              _detailTile(
                Icons.calendar_today,
                Colors.blue,
                'التاريخ',
                s['session_date'] ?? '',
              ),
              _detailTile(Icons.access_time, Colors.teal, 'الوقت', displayTime),
              _detailTile(
                Icons.meeting_room,
                Colors.orange,
                'القاعة',
                s['location'] ?? '',
              ),
              if ((s['notes'] ?? '').toString().isNotEmpty)
                _detailTile(
                  Icons.note_outlined,
                  Colors.grey,
                  'ملاحظات',
                  s['notes'],
                ),

              const SizedBox(height: 16),

              // ── قائمة الأطفال ──
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${children.length} طفل',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'الأطفال المشاركون',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.child_care,
                    color: Color(0xFF2575FC),
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 10),

              children.isEmpty
                  ? const Center(
                      child: Text(
                        'لا يوجد أطفال',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : Column(
                      children: children.map((child) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2575FC).withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF2575FC).withOpacity(0.15),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${child['age']} سنة',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                child['name'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),

              const SizedBox(height: 20),

              // ── أزرار التحكم ──
              if (!isCancelled)
                Row(
                  children: [
                    // إلغاء الجلسة
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.cancel_outlined),
                        label: const Text('إلغاء الجلسة'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _confirmCancel(int.parse(s['id'].toString()));
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Toggle Done
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(
                          isDone ? Icons.undo : Icons.check_circle_outline,
                        ),
                        label: Text(isDone ? 'إلغاء التمام' : 'تمت'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDone
                              ? Colors.orange
                              : Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _toggleStatus(
                            int.parse(s['id'].toString()),
                            s['status'],
                          );
                        },
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── تأكيد إلغاء الجلسة ──────────────────────────────────────
  void _confirmCancel(int sessionId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'إلغاء الجلسة',
          textAlign: TextAlign.right,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'هل أنت متأكد من إلغاء هذه الجلسة؟',
          textAlign: TextAlign.right,
        ),
        actionsAlignment: MainAxisAlignment.start,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('لا', style: TextStyle(color: Colors.blueGrey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _cancelSession(sessionId);
            },
            child: const Text(
              'نعم، إلغاء',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ── إلغاء الجلسة في الـ API ─────────────────────────────────
  Future<void> _cancelSession(int sessionId) async {
    try {
      final res = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/sessions/update_session_status.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'session_id': sessionId, 'status': 'cancelled'}),
      );
      final data = jsonDecode(res.body);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? ''),
            backgroundColor: data['status'] == true
                ? Colors.orange
                : Colors.red,
          ),
        );
        if (data['status'] == true) _fetchSessions();
      }
    } catch (e) {
      debugPrint('cancelSession: $e');
    }
  }

  // ── Detail Tile مساعد ────────────────────────────────────────
  Widget _detailTile(IconData icon, Color color, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(icon, color: color, size: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String val, String label, Color color) => Column(
    children: [
      Text(
        val,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
      Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
    ],
  );

  Widget _sectionLabel(String text) => Align(
    alignment: Alignment.centerRight,
    child: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
    ),
  );

  Widget _dropdown({
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) => DropdownButtonFormField<String>(
    value: value,
    isExpanded: true,
    decoration: InputDecoration(
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    ),
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

  String _spTypeLabel(String type) {
    switch (type) {
      case 'speech':
        return 'تخاطب';
      case 'psychologist':
        return 'نفسي';
      case 'behavior':
        return 'تعديل سلوك';
      case 'special_education':
        return 'تربية خاصة';
      case 'occupational_therapy':
        return 'علاج وظيفي';
      default:
        return type;
    }
  }

  String _monthName(int month) {
    const months = [
      '',
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return months[month];
  }

  String _dayName(int weekday) {
    const days = [
      '',
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];
    return days[weekday];
  }
}
