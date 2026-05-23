import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../../core/constants/api_constants.dart';

class WaitingListScreen extends StatefulWidget {
  const WaitingListScreen({super.key});
  @override
  State<WaitingListScreen> createState() => _WaitingListScreenState();
}

class _WaitingListScreenState extends State<WaitingListScreen> {
  List<Map<String, dynamic>> _cases = [];
  List<Map<String, dynamic>> _families = [];
  List<Map<String, dynamic>> _specialists = [];

  bool _isLoading = true;
  String _selectedFilter = 'الكل';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filters = [
    'الكل',
    'تخاطب',
    'تعديل سلوك',
    'اختبار ذكاء',
    'تنمية مهارات',
    'أكاديمي',
    'جلسات تكامل',
  ];

  // ✅ ترجمة كل التخصصات الجديدة
  String _translateType(String? type) {
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
        return type ?? '';
    }
  }

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _fetchWaitingList(),
      _fetchFamilies(),
      _fetchSpecialists(),
    ]);
    setState(() => _isLoading = false);
  }

  Future<void> _fetchWaitingList() async {
    try {
      final res = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}/children/get_waiting_list.php?status=pending',
        ),
      );
      final data = jsonDecode(res.body);
      if (data['status'] == true) {
        _cases = List<Map<String, dynamic>>.from(data['data']);
      }
    } catch (e) {
      debugPrint('fetchWaitingList: $e');
    }
  }

  Future<void> _fetchFamilies() async {
    try {
      final res = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/families/get_families.php'),
      );
      final data = jsonDecode(res.body);
      if (data['status'] == true) {
        _families = List<Map<String, dynamic>>.from(data['data']);
      }
    } catch (e) {
      debugPrint('fetchFamilies: $e');
    }
  }

  Future<void> _fetchSpecialists() async {
    try {
      final res = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/specialists/get_specialists.php'),
      );
      final data = jsonDecode(res.body);
      if (data['status'] == true) {
        _specialists = List<Map<String, dynamic>>.from(data['data']);
      }
    } catch (e) {
      debugPrint('fetchSpecialists: $e');
    }
  }

  // ════════════════════════════════════════════════════
  // APPROVE
  // ════════════════════════════════════════════════════
  Future<void> _approveCase(
    int waitingId,
    int familyId,
    List<int> specialistIds,
  ) async {
    try {
      final res = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/children/approve_child.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'waiting_id': waitingId,
          'family_id': familyId,
          'diagnosis': '',
          'specialist_ids': specialistIds,
        }),
      );
      final data = jsonDecode(res.body);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? ''),
            backgroundColor: data['status'] == true ? Colors.green : Colors.red,
          ),
        );
        if (data['status'] == true) _loadAll();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('خطأ في الاتصال'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ════════════════════════════════════════════════════
  // REJECT
  // ════════════════════════════════════════════════════
  Future<void> _rejectCase(int waitingId) async {
    try {
      final res = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/children/reject_child.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'waiting_id': waitingId}),
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
        if (data['status'] == true) _loadAll();
      }
    } catch (e) {
      debugPrint('rejectCase: $e');
    }
  }

  // ════════════════════════════════════════════════════
  // BOTTOM SHEET — تفاصيل الحالة
  // ════════════════════════════════════════════════════
  void _showCaseDetails(Map<String, dynamic> item) {
    int? selectedFamilyId = null;
    List<int> selectedSpecialistIds = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.92,
          maxChildSize: 0.97,
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

                // ── عنوان ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(
                      'بيانات الطفل',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.child_care, color: Color(0xFF2575FC)),
                  ],
                ),
                const Divider(height: 25),

                // ── بيانات ──
                _detailRow('الاسم', item['name'] ?? ''),
                _detailRow('العمر', '${item['age'] ?? ''} سنة'),
                _detailRow('الهاتف', item['phone'] ?? ''),
                _detailRow('الخدمة المطلوبة', item['service_type'] ?? ''),
                _detailRow('الإيميل', item['email'] ?? ''),
                _detailRow(
                  'تاريخ التسجيل',
                  (item['created_at'] ?? '').toString().length >= 10
                      ? item['created_at'].toString().substring(0, 10)
                      : '',
                ),

                const SizedBox(height: 24),

                // ── اختيار الأسرة ──
                _sectionHeader(
                  'تحديد الأسرة المناسبة',
                  Icons.groups_rounded,
                  Colors.blue,
                ),
                const SizedBox(height: 8),
                _families.isEmpty
                    ? _emptyHint('لا توجد أسر متاحة')
                    : DropdownButtonFormField<int>(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          hintText: 'اختر الأسرة',
                        ),
                        hint: const Text('اختر الأسرة'),
                        items: _families
                            .map(
                              (f) => DropdownMenuItem<int>(
                                value: int.tryParse(f['id'].toString()) ?? 0,
                                child: Text(f['name'] ?? ''),
                              ),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setModal(() => selectedFamilyId = val),
                      ),

                const SizedBox(height: 24),

                // ── اختيار الأخصائيين ──
                _sectionHeader(
                  'تعيين أخصائي مسؤول',
                  Icons.medical_services_rounded,
                  Colors.purple,
                ),
                const SizedBox(height: 8),
                _specialists.isEmpty
                    ? _emptyHint('لا يوجد أخصائيون')
                    : Column(
                        children: _specialists.map((sp) {
                          final spId = int.tryParse(sp['id'].toString()) ?? 0;
                          final typeAr = _translateType(sp['specialist_type']);
                          final sel = selectedSpecialistIds.contains(spId);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: sel
                                    ? const Color(0xFF2575FC)
                                    : Colors.grey.shade200,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              color: sel
                                  ? const Color(0xFF2575FC).withOpacity(0.05)
                                  : Colors.white,
                            ),
                            child: CheckboxListTile(
                              title: Text(
                                sp['full_name'] ?? '',
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Text(
                                '${sp['family_name'] ?? ''}  •  $typeAr',
                                textAlign: TextAlign.right,
                                style: const TextStyle(fontSize: 12),
                              ),
                              value: sel,
                              activeColor: const Color(0xFF2575FC),
                              onChanged: (checked) => setModal(() {
                                if (checked == true) {
                                  selectedSpecialistIds.add(spId);
                                } else {
                                  selectedSpecialistIds.remove(spId);
                                }
                              }),
                            ),
                          );
                        }).toList(),
                      ),

                const SizedBox(height: 24),

                // ── أزرار الموافقة والرفض ──
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('موافقة وقبول'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          if (selectedFamilyId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('يرجى اختيار أسرة أولاً'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }
                          Navigator.pop(ctx);
                          await _approveCase(
                            int.tryParse(item['id'].toString()) ?? 0,
                            selectedFamilyId!,
                            selectedSpecialistIds,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.cancel_outlined),
                        label: const Text('رفض'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await _rejectCase(
                            int.tryParse(item['id'].toString()) ?? 0,
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
      ),
    );
  }

  // ════════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final filtered = _cases.where((c) {
      final matchFilter =
          _selectedFilter == 'الكل' || c['service_type'] == _selectedFilter;
      final matchSearch =
          _searchController.text.isEmpty ||
          (c['name'] ?? '').contains(_searchController.text);
      return matchFilter && matchSearch;
    }).toList();

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
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadAll),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ── Search ──
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: TextField(
                    controller: _searchController,
                    textAlign: TextAlign.right,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'ابحث عن اسم الطفل...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                // ── Filters ──
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    children: _filters
                        .map(
                          (f) => Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: FilterChip(
                              label: Text(f),
                              selected: _selectedFilter == f,
                              onSelected: (_) =>
                                  setState(() => _selectedFilter = f),
                              selectedColor: const Color(
                                0xFF2575FC,
                              ).withOpacity(0.15),
                              checkmarkColor: const Color(0xFF2575FC),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),

                const SizedBox(height: 8),

                // ── Count ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${filtered.length} حالة',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const Text(
                        'قيد الانتظار',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 5),

                // ── List ──
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.hourglass_empty,
                                size: 60,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 10),
                              Text(
                                'لا توجد حالات في قائمة الانتظار',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(15),
                          itemCount: filtered.length,
                          itemBuilder: (_, i) {
                            final item = filtered[i];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(12),
                                leading: const CircleAvatar(
                                  backgroundColor: Color(0xFFEEF2FF),
                                  child: Icon(
                                    Icons.child_care,
                                    color: Color(0xFF2575FC),
                                  ),
                                ),
                                title: Text(
                                  item['name'] ?? '',
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  'الخدمة: ${item['service_type'] ?? ''}\nالعمر: ${item['age'] ?? ''} سنة',
                                  textAlign: TextAlign.right,
                                ),
                                trailing: ElevatedButton(
                                  onPressed: () => _showCaseDetails(item),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2575FC),
                                    shape: const StadiumBorder(),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'مراجعة',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
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

  // ── helpers ─────────────────────────────────────────
  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
          ),
          Text('$label :', style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Icon(icon, color: color, size: 20),
      ],
    );
  }

  Widget _emptyHint(String msg) {
    return Center(
      child: Text(msg, style: const TextStyle(color: Colors.grey)),
    );
  }
}
