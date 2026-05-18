import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../../core/constants/api_constants.dart';
import '../children/child_details_screen.dart';
import 'package:college_project/core/enums/user_role.dart';

class SpecialistDashboardScreen extends StatefulWidget {
  final int specialistId;
  final String specialistName;
  final String specialistType; // 'speech' | 'psychologist' | 'behavior'

  const SpecialistDashboardScreen({
    super.key,
    required this.specialistId,
    required this.specialistName,
    required this.specialistType,
  });

  @override
  State<SpecialistDashboardScreen> createState() =>
      _SpecialistDashboardScreenState();
}

class _SpecialistDashboardScreenState extends State<SpecialistDashboardScreen> {
  bool isLoading = true;

  List<Map<String, dynamic>> myChildren = [];
  List<Map<String, dynamic>> myCurriculum = [];
  List<Map<String, dynamic>> mySessions = [];

  // اسم التخصص بالعربي
  String get specialistTypeLabel {
    switch (widget.specialistType) {
      case 'speech':
        return 'تخاطب';
      case 'psychologist':
        return 'نفسي';
      case 'behavior':
        return 'تعديل سلوك';
      default:
        return '';
    }
  }

  Color get specialistColor {
    switch (widget.specialistType) {
      case 'speech':
        return const Color(0xFFE65100);
      case 'psychologist':
        return const Color(0xFF2E7D32);
      case 'behavior':
        return const Color(0xFF1565C0);
      default:
        return const Color(0xFF6A11CB);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    await Future.wait([_loadChildren(), _loadCurriculum()]);
    setState(() => isLoading = false);
  }

  Future<void> _loadChildren() async {
    try {
      final res = await http
          .get(
            Uri.parse(
              '${ApiConstants.baseUrl}/specialists/get_specialist_children.php?specialist_id=${widget.specialistId}',
            ),
          )
          .timeout(const Duration(seconds: 15));
      final data = jsonDecode(res.body);
      if (data['status'] == true) {
        myChildren = List<Map<String, dynamic>>.from(data['data']);
      }
    } catch (_) {}
  }

  Future<void> _loadCurriculum() async {
    try {
      final res = await http
          .get(
            Uri.parse(
              '${ApiConstants.baseUrl}/curriculum/get_specialist_curriculum.php?specialist_id=${widget.specialistId}',
            ),
          )
          .timeout(const Duration(seconds: 15));
      final data = jsonDecode(res.body);
      if (data['status'] == true) {
        myCurriculum = List<Map<String, dynamic>>.from(data['data']);
      }
    } catch (_) {}
  }

  // ════════════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                // ── Header ──────────────────────────────────
                SliverAppBar(
                  expandedHeight: 200,
                  pinned: true,
                  backgroundColor: specialistColor,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            specialistColor,
                            specialistColor.withValues(alpha: 0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: SafeArea(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.2,
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 45,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              widget.specialistName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'أخصائي $specialistTypeLabel',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  iconTheme: const IconThemeData(color: Colors.white),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // ── Stats Row ──────────────────────────
                        Row(
                          children: [
                            Expanded(
                              child: _statCard(
                                label: 'الأطفال',
                                value: '${myChildren.length}',
                                icon: Icons.child_care,
                                color: specialistColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _statCard(
                                label: 'مناهج',
                                value: '${myCurriculum.length}',
                                icon: Icons.menu_book,
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _statCard(
                                label: 'جلسات',
                                value: '${mySessions.length}',
                                icon: Icons.event_note,
                                color: Colors.teal,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // ── أطفالي ─────────────────────────────
                        _sectionTitle(
                          'أطفالي',
                          Icons.child_care,
                          specialistColor,
                        ),
                        const SizedBox(height: 12),
                        myChildren.isEmpty
                            ? _emptyState('لا يوجد أطفال مسندون إليك')
                            : SizedBox(
                                height: 130,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  reverse: true,
                                  itemCount: myChildren.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 12),
                                  itemBuilder: (_, i) {
                                    final child = myChildren[i];
                                    return GestureDetector(
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ChildDetailsScreen(
                                            childId: child['id'],
                                            childName: child['name'],
                                            currentUserRole:
                                                UserRole.specialist,
                                          ),
                                        ),
                                      ),
                                      child: _childCard(child, specialistColor),
                                    );
                                  },
                                ),
                              ),
                        const SizedBox(height: 24),

                        // ── المنهج ─────────────────────────────
                        _sectionTitle(
                          'المنهج والجلسات',
                          Icons.menu_book,
                          Colors.orange,
                        ),
                        const SizedBox(height: 12),
                        myCurriculum.isEmpty
                            ? _emptyState('لم يتم رفع منهج بعد')
                            : Column(
                                children: myCurriculum
                                    .map((c) => _curriculumCard(c))
                                    .toList(),
                              ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // ─── Widgets ────────────────────────────────────────────

  Widget _statCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Icon(icon, color: color, size: 20),
      ],
    );
  }

  Widget _childCard(Map child, Color color) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: color.withValues(alpha: 0.1),
            child: Icon(Icons.face, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            child['name'] ?? '',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          Text(
            '${child['age']} سنة',
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _curriculumCard(Map curriculum) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            curriculum['created_at']?.toString().substring(0, 10) ?? '',
            style: TextStyle(fontSize: 12, color: Colors.grey[400]),
          ),
          const SizedBox(height: 8),
          if ((curriculum['comment'] ?? '').toString().isNotEmpty)
            _curriculumRow(
              Icons.comment_outlined,
              Colors.purple,
              'تعليق',
              curriculum['comment'],
            ),
          if ((curriculum['exercise'] ?? '').toString().isNotEmpty)
            _curriculumRow(
              Icons.fitness_center,
              Colors.deepOrange,
              'تمرين',
              curriculum['exercise'],
            ),
          if ((curriculum['treatment'] ?? '').toString().isNotEmpty)
            _curriculumRow(
              Icons.healing,
              Colors.teal,
              'علاج',
              curriculum['treatment'],
            ),
          // PDF & media indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if ((curriculum['pdf_paths'] ?? '[]') != '[]')
                _mediaChip(Icons.picture_as_pdf, Colors.red, 'PDF'),
              const SizedBox(width: 6),
              if ((curriculum['image_paths'] ?? '[]') != '[]')
                _mediaChip(Icons.image, Colors.blue, 'صور'),
              const SizedBox(width: 6),
              if (curriculum['video_path'] != null)
                _mediaChip(Icons.videocam, Colors.purple, 'فيديو'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _curriculumRow(IconData icon, Color color, String label, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(icon, color: color, size: 13),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mediaChip(IconData icon, Color color, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 11)),
          const SizedBox(width: 4),
          Icon(icon, color: color, size: 13),
        ],
      ),
    );
  }

  Widget _emptyState(String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 40, color: Colors.grey[300]),
          const SizedBox(height: 8),
          Text(msg, style: TextStyle(color: Colors.grey[400], fontSize: 13)),
        ],
      ),
    );
  }
}
