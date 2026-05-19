import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../../core/constants/api_constants.dart';
import '../auth/login_screen.dart'; // ← للـ logout
import '../children/child_details_screen.dart';
import '../children/children_list_screen.dart';
import 'package:college_project/core/enums/user_role.dart';

class SpecialistDashboardScreen extends StatefulWidget {
  final int specialistId;
  final String specialistName;
  final String specialistType;
  final int familyId;
  final String familyName;

  const SpecialistDashboardScreen({
    super.key,
    required this.specialistId,
    required this.specialistName,
    required this.specialistType,
    this.familyId = 0,
    this.familyName = '',
  });

  @override
  State<SpecialistDashboardScreen> createState() =>
      _SpecialistDashboardScreenState();
}

class _SpecialistDashboardScreenState extends State<SpecialistDashboardScreen> {
  bool isLoading = true;

  List<Map<String, dynamic>> myChildren = [];
  List<Map<String, dynamic>> myCurriculum = [];

  // ── التخصص بالعربي ──────────────────────────────────────
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
    if (mounted) setState(() => isLoading = false);
  }

  Future<void> _loadChildren() async {
    try {
      final res = await http
          .get(
            Uri.parse(
              '${ApiConstants.baseUrl}/children/get_specialist_children.php?specialist_id=${widget.specialistId}',
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

  // ── تسجيل الخروج ────────────────────────────────────────
  void _logout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'تسجيل الخروج',
          textAlign: TextAlign.right,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'هل تريد تسجيل الخروج؟',
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('خروج'),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),

      appBar: AppBar(
        backgroundColor: specialistColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: widget.familyId > 0
            ? GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChildrenListScreen(
                      familyId: widget.familyId,
                      familyName: widget.familyName,
                      isSpecialist: false,
                    ),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.groups_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.familyName.isNotEmpty
                            ? widget.familyName
                            : 'الأسرة',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 12,
                      ),
                    ],
                  ),
                ),
              )
            : null,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'تسجيل الخروج',
            onPressed: _logout,
          ),
        ],
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async => _loadAll(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // ── Profile Header ──────────────────────
                    Container(
                      width: double.infinity,
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
                      padding: const EdgeInsets.only(top: 20, bottom: 40),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 45,
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.2,
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 50,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.specialistName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
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

                    // ── Stats ───────────────────────────────
                    Transform.translate(
                      offset: const Offset(0, -20),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
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
                                label: 'المناهج',
                                value: '${myCurriculum.length}',
                                icon: Icons.menu_book,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── Body ────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // ── أطفالي ────────────────────────
                          _sectionHeader(
                            'جميع الأطفال التابعين لي',
                            Icons.child_care,
                            specialistColor,
                          ),
                          const SizedBox(height: 12),

                          myChildren.isEmpty
                              ? _emptyState(
                                  'لا يوجد أطفال مسندون إليك',
                                  Icons.child_care_outlined,
                                )
                              : GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        mainAxisSpacing: 12,
                                        crossAxisSpacing: 12,
                                        childAspectRatio: 0.85,
                                      ),
                                  itemCount: myChildren.length,
                                  itemBuilder: (_, i) {
                                    final child = myChildren[i];
                                    return GestureDetector(
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ChildDetailsScreen(
                                            childId: child['id'] is int
                                                ? child['id']
                                                : int.parse(
                                                    child['id'].toString(),
                                                  ),
                                            childName: child['name'] ?? '',
                                            currentUserRole:
                                                UserRole.specialist,
                                            currentUserId:
                                                widget.specialistId, // ← مُصلح
                                          ),
                                        ),
                                      ),
                                      child: _childCard(child, specialistColor),
                                    );
                                  },
                                ),

                          const SizedBox(height: 28),

                          // ── المنهج ────────────────────────
                          _sectionHeader(
                            'المنهج والجلسات',
                            Icons.menu_book,
                            Colors.orange,
                          ),
                          const SizedBox(height: 12),

                          myCurriculum.isEmpty
                              ? _emptyState(
                                  'لم يتم رفع منهج بعد',
                                  Icons.menu_book_outlined,
                                )
                              : Column(
                                  children: myCurriculum
                                      .map((c) => _curriculumCard(c))
                                      .toList(),
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // ════════════════════════════════════════════════════════
  // WIDGETS
  // ════════════════════════════════════════════════════════

  Widget _statCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
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
            fontSize: 17,
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color.withValues(alpha: 0.1),
            child: Icon(Icons.face_retouching_natural, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              child['name'] ?? '',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '${child['age']} سنة',
            style: TextStyle(fontSize: 10, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _curriculumCard(Map curriculum) {
    final comment = (curriculum['comment'] ?? '').toString().trim();
    final exercise = (curriculum['exercise'] ?? '').toString().trim();
    final treatment = (curriculum['treatment'] ?? '').toString().trim();
    final pdfPaths = (curriculum['pdf_paths'] ?? '').toString();
    final imgPaths = (curriculum['image_paths'] ?? '').toString();
    final videoPath = (curriculum['video_path'] ?? '').toString().trim();

    final hasPdf =
        pdfPaths.isNotEmpty && pdfPaths != '[]' && pdfPaths != 'null';
    final hasImages =
        imgPaths.isNotEmpty && imgPaths != '[]' && imgPaths != 'null';
    final hasVideo = videoPath.isNotEmpty && videoPath != 'null';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  curriculum['created_at']?.toString().length != null &&
                          curriculum['created_at'].toString().length >= 10
                      ? curriculum['created_at'].toString().substring(0, 10)
                      : '',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.calendar_today, size: 13, color: Colors.orange[700]),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (comment.isNotEmpty) ...[
                  _contentSection(
                    Icons.comment_outlined,
                    Colors.purple,
                    'التعليق',
                    comment,
                  ),
                  const SizedBox(height: 10),
                ],
                if (exercise.isNotEmpty) ...[
                  _contentSection(
                    Icons.fitness_center,
                    Colors.deepOrange,
                    'التمرين',
                    exercise,
                  ),
                  const SizedBox(height: 10),
                ],
                if (treatment.isNotEmpty) ...[
                  _contentSection(
                    Icons.healing,
                    Colors.teal,
                    'الخطة العلاجية',
                    treatment,
                  ),
                  const SizedBox(height: 10),
                ],
                if (!comment.isNotEmpty &&
                    !exercise.isNotEmpty &&
                    !treatment.isNotEmpty &&
                    !hasPdf &&
                    !hasImages &&
                    !hasVideo)
                  Center(
                    child: Text(
                      'لا يوجد محتوى',
                      style: TextStyle(color: Colors.grey[400], fontSize: 13),
                    ),
                  ),
                if (hasPdf || hasImages || hasVideo) ...[
                  const Divider(),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (hasPdf)
                        _mediaChip(Icons.picture_as_pdf, Colors.red, 'PDF'),
                      if (hasPdf) const SizedBox(width: 8),
                      if (hasImages)
                        _mediaChip(Icons.image, Colors.blue, 'صور'),
                      if (hasImages) const SizedBox(width: 8),
                      if (hasVideo)
                        _mediaChip(Icons.videocam, Colors.purple, 'فيديو'),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _contentSection(
    IconData icon,
    Color color,
    String label,
    String text,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 6),
              Icon(icon, color: color, size: 15),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            text,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _mediaChip(IconData icon, Color color, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 12)),
          const SizedBox(width: 4),
          Icon(icon, color: color, size: 14),
        ],
      ),
    );
  }

  Widget _emptyState(String msg, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, size: 42, color: Colors.grey[300]),
          const SizedBox(height: 10),
          Text(msg, style: TextStyle(color: Colors.grey[400], fontSize: 13)),
        ],
      ),
    );
  }
}
