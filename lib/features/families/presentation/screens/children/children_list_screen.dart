import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../../core/constants/api_constants.dart';
import 'child_details_screen.dart';
import 'package:college_project/core/enums/user_role.dart';
import '../psychologists/specialist_curriculum_screens.dart';

class ChildrenListScreen extends StatefulWidget {
  final int familyId;
  final String familyName;
  final bool isSpecialist;
  final int specialistId;
  final UserRole currentUserRole;
  final int currentUserId;

  const ChildrenListScreen({
    super.key,
    required this.familyId,
    required this.familyName,
    this.isSpecialist = false,
    this.specialistId = 0,
    this.currentUserRole = UserRole.familyManager,
    required this.currentUserId,
  });

  @override
  State<ChildrenListScreen> createState() => _ChildrenListScreenState();
}

class _ChildrenListScreenState extends State<ChildrenListScreen> {
  bool isLoadingChildren = true;
  bool isLoadingSpecialists = true;
  bool isLoadingSessions = true;
  bool isLoadingManagers = true;

  List children = [];
  List filteredChildren = [];
  List specialists = [];
  List sessions = [];
  List managers = [];
  Map sessionStats = {};

  bool showManagers = true;
  bool showSpecialists = true;
  bool showSessions = true;
  bool showChildren = true;

  final TextEditingController searchController = TextEditingController();

  // ===================== INIT =====================

  @override
  void initState() {
    super.initState();
    _loadAll();
    searchController.addListener(() => _onSearch(searchController.text));
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    await Future.wait([
      getChildren(),
      getSpecialists(),
      getSessions(),
      getManagers(),
    ]);
  }

  // ===================== APIs =====================

  Future<void> getChildren() async {
    setState(() => isLoadingChildren = true);
    try {
      final url = widget.isSpecialist
          ? "${ApiConstants.baseUrl}/children/get_specialist_children.php?specialist_id=${widget.specialistId}"
          : "${ApiConstants.baseUrl}/children/get_children.php?family_id=${widget.familyId}";

      final response = await http.get(Uri.parse(url));
      final data = jsonDecode(response.body);
      if (data['status'] == true) {
        setState(() {
          children = data['data'];
          filteredChildren = data['data'];
        });
      }
    } catch (_) {}
    setState(() => isLoadingChildren = false);
  }

  Future<void> getSpecialists() async {
    setState(() => isLoadingSpecialists = true);
    try {
      final response = await http.get(
        Uri.parse(
          "${ApiConstants.baseUrl}/specialists/get_all_specialists.php?family_id=${widget.familyId}",
        ),
      );
      final data = jsonDecode(response.body);
      if (data['status'] == true) {
        setState(() => specialists = data['data']);
      }
    } catch (_) {}
    setState(() => isLoadingSpecialists = false);
  }

  Future<void> getSessions() async {
    setState(() => isLoadingSessions = true);
    try {
      final response = await http.get(
        Uri.parse(
          "${ApiConstants.baseUrl}/sessions/get_family_sessions.php?family_id=${widget.familyId}",
        ),
      );
      final data = jsonDecode(response.body);
      if (data['status'] == true) {
        setState(() {
          sessions = data['data'];
          sessionStats = data['stats'] ?? {};
        });
      }
    } catch (_) {}
    setState(() => isLoadingSessions = false);
  }

  Future<void> getManagers() async {
    setState(() => isLoadingManagers = true);
    try {
      final response = await http.get(
        Uri.parse(
          "${ApiConstants.baseUrl}/families/get_family_managers.php?family_id=${widget.familyId}",
        ),
      );
      final data = jsonDecode(response.body);
      if (data['status'] == true) {
        setState(() => managers = data['data']);
      }
    } catch (_) {}
    setState(() => isLoadingManagers = false);
  }

  // ===================== SEARCH =====================

  void _onSearch(String query) {
    setState(() {
      filteredChildren = query.isEmpty
          ? children
          : children
                .where(
                  (c) => c['name'].toString().toLowerCase().contains(
                    query.toLowerCase(),
                  ),
                )
                .toList();
    });
  }

  // ===================== HELPERS =====================

  String _typeLabel(String type) {
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

  Color _typeColor(String type) {
    switch (type) {
      case 'speech':
        return const Color(0xFFE65100);
      case 'psychologist':
        return const Color(0xFF2E7D32);
      case 'behavior':
        return const Color(0xFF1565C0);
      case 'special_education':
        return const Color(0xFF6A1B9A);
      case 'occupational_therapy':
        return const Color(0xFF00695C);
      default:
        return const Color(0xFF6A11CB);
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'speech':
        return Icons.record_voice_over;
      case 'psychologist':
        return Icons.psychology;
      case 'behavior':
        return Icons.self_improvement;
      case 'special_education':
        return Icons.school;
      case 'occupational_therapy':
        return Icons.accessibility_new;
      default:
        return Icons.person;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'done':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'done':
        return 'منتهية';
      case 'cancelled':
        return 'ملغية';
      default:
        return 'قادمة';
    }
  }

  // ===================== BUILD =====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: Text(
          widget.familyName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file_rounded, color: Colors.indigo),
            tooltip: 'رفع المنهج',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    SpecialistSelectionScreen(familyId: widget.familyId),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAll,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // ══════════════ 0. مسؤولو الأسرة ══════════════
              _collapsibleSection(
                title: 'مسؤولو الأسرة',
                icon: Icons.manage_accounts_outlined,
                color: const Color(0xFF2E7D32),
                isExpanded: showManagers,
                onToggle: () => setState(() => showManagers = !showManagers),
                child: isLoadingManagers
                    ? _loadingWidget()
                    : managers.isEmpty
                    ? _emptyHint('لا يوجد مسؤولون')
                    : Column(
                        children: managers.map<Widget>((m) {
                          final isManager = m['role'] == 'family_manager';
                          final color = isManager
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFF1565C0);
                          final roleLabel = isManager
                              ? 'مسؤول الأسرة'
                              : 'مساعد';
                          final roleIcon = isManager
                              ? Icons.admin_panel_settings_outlined
                              : Icons.support_agent_outlined;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: color.withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                // المعلومات
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        m['full_name'] ?? '',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: color,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      if ((m['phone'] ?? '').isNotEmpty)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text(
                                              m['phone'],
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            const Icon(
                                              Icons.phone_outlined,
                                              size: 12,
                                              color: Colors.grey,
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 12),

                                // الأيقونة والرتبة
                                Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 22,
                                      backgroundColor: color.withOpacity(0.12),
                                      child: Icon(
                                        roleIcon,
                                        color: color,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: color.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        roleLabel,
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: color,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
              ),

              // ══════════════ 1. الأخصائيين ══════════════
              _collapsibleSection(
                title: 'الأخصائيين المسؤولين',
                icon: Icons.medical_services_outlined,
                color: const Color(0xFF1565C0),
                isExpanded: showSpecialists,
                onToggle: () =>
                    setState(() => showSpecialists = !showSpecialists),
                child: isLoadingSpecialists
                    ? _loadingWidget()
                    : specialists.isEmpty
                    ? _emptyHint('لا يوجد أخصائيين')
                    : SizedBox(
                        height: 105,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          reverse: true,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          itemCount: specialists.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 10),
                          itemBuilder: (_, i) {
                            final sp = specialists[i];
                            final type =
                                sp['specialist_type']?.toString() ?? '';
                            return _specialistCard(
                              name: sp['full_name'] ?? '',
                              type: _typeLabel(type),
                              icon: _typeIcon(type),
                              color: _typeColor(type),
                            );
                          },
                        ),
                      ),
              ),

              // ══════════════ 2. الجلسات ══════════════════
              _collapsibleSection(
                title: 'الجلسات',
                icon: Icons.event_note_outlined,
                color: Colors.deepPurple,
                isExpanded: showSessions,
                onToggle: () => setState(() => showSessions = !showSessions),
                child: isLoadingSessions
                    ? _loadingWidget()
                    : sessions.isEmpty
                    ? _emptyHint('لا توجد جلسات')
                    : Column(
                        children: [
                          if (sessionStats.isNotEmpty) ...[
                            _statsRow(),
                            const SizedBox(height: 12),
                          ],
                          ...sessions.map<Widget>((s) => _sessionCard(s)),
                        ],
                      ),
              ),

              // ══════════════ 3. الأطفال ══════════════════
              _collapsibleSection(
                title: 'الأطفال',
                icon: Icons.child_care_outlined,
                color: const Color(0xFF6A11CB),
                isExpanded: showChildren,
                onToggle: () => setState(() => showChildren = !showChildren),
                child: Column(
                  children: [
                    // البحث
                    TextField(
                      controller: searchController,
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        hintText: 'ابحث عن اسم الطفل...',
                        hintTextDirection: TextDirection.rtl,
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        suffixIcon: searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  searchController.clear();
                                  _onSearch('');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: const Color(0xFFF4F7FA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF6A11CB),
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    isLoadingChildren
                        ? _loadingWidget()
                        : filteredChildren.isEmpty
                        ? Column(
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 40,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                searchController.text.isNotEmpty
                                    ? 'لا نتائج لـ "${searchController.text}"'
                                    : 'لا يوجد أطفال',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filteredChildren.length,
                            itemBuilder: (_, i) =>
                                _childCard(filteredChildren[i]),
                          ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ===================== COLLAPSIBLE SECTION =====================

  Widget _collapsibleSection({
    required String title,
    required IconData icon,
    required Color color,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(15, 15, 15, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(20),
              bottom: isExpanded ? Radius.zero : const Radius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  AnimatedRotation(
                    turns: isExpanded ? 0 : -0.25,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: color,
                      size: 22,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(icon, color: color, size: 18),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: child,
            ),
            secondChild: const SizedBox.shrink(),
            crossFadeState: isExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

  // ===================== STATS ROW =====================

  Widget _statsRow() {
    return Row(
      children: [
        Expanded(
          child: _statChip(
            '${sessionStats['total'] ?? 0}',
            'إجمالي',
            Colors.deepPurple,
            Icons.event_note,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _statChip(
            '${sessionStats['done'] ?? 0}',
            'منتهية',
            Colors.green,
            Icons.check_circle_outline,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _statChip(
            '${sessionStats['pending'] ?? 0}',
            'قادمة',
            Colors.orange,
            Icons.schedule,
          ),
        ),
      ],
    );
  }

  Widget _statChip(String value, String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: color.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }

  // ===================== SPECIALIST CARD =====================

  Widget _specialistCard({
    required String name,
    required String type,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 82,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 6),
          Text(
            name.split(' ').take(2).join(' '),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            type,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 8,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ===================== CHILD CARD =====================

  Widget _childCard(Map child) {
    final spNames = child['specialists']?.toString() ?? '';
    final diagnosis = child['diagnosis']?.toString() ?? '';
    final age = child['age']?.toString() ?? '';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChildDetailsScreen(
            childId: int.parse(child['id'].toString()),
            childName: child['name'],
            currentUserRole: widget.currentUserRole,
            currentUserId: widget.currentUserId,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FD),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF6A11CB).withOpacity(0.1)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                Icons.arrow_back_ios_new,
                size: 13,
                color: const Color(0xFF6A11CB).withOpacity(0.5),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      child['name'] ?? '',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (age.isNotEmpty)
                          _infoChip(
                            '$age سنة',
                            Icons.cake_outlined,
                            Colors.deepPurple,
                          ),
                        if (diagnosis.isNotEmpty)
                          _infoChip(
                            diagnosis,
                            Icons.medical_information_outlined,
                            Colors.teal,
                          ),
                      ],
                    ),
                    if (spNames.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Text(
                              spNames,
                              textAlign: TextAlign.right,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF1565C0),
                              ),
                            ),
                          ),
                          const SizedBox(width: 3),
                          const Icon(
                            Icons.person_outline,
                            size: 12,
                            color: Color(0xFF1565C0),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF6A11CB).withOpacity(0.1),
                child: const Icon(
                  Icons.face_retouching_natural,
                  color: Color(0xFF6A11CB),
                  size: 26,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 3),
          Icon(icon, size: 10, color: color),
        ],
      ),
    );
  }

  // ===================== SESSION CARD =====================

  Widget _sessionCard(Map session) {
    final spName = session['specialist_name']?.toString() ?? '';
    final spType = session['specialist_type']?.toString() ?? '';
    final status = session['status']?.toString() ?? 'pending';
    final date = session['session_date']?.toString() ?? '';
    final time = session['session_time']?.toString() ?? '';
    final location = session['location']?.toString() ?? '';
    final type = session['session_type']?.toString() ?? '';
    final notes = session['notes']?.toString() ?? '';
    final children = session['children'] as List? ?? [];

    final color = _typeColor(spType);
    final statusColor = _statusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.07),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    _statusLabel(status),
                    style: TextStyle(
                      fontSize: 10,
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          spName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        Text(
                          _typeLabel(spType),
                          style: TextStyle(
                            fontSize: 10,
                            color: color.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      radius: 15,
                      backgroundColor: color.withOpacity(0.15),
                      child: Icon(_typeIcon(spType), color: color, size: 15),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (location.isNotEmpty) ...[
                      Text(
                        location,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Icon(
                        Icons.location_on_outlined,
                        size: 12,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 10),
                    ],
                    Text(
                      time,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    const SizedBox(width: 3),
                    const Icon(Icons.access_time, size: 12, color: Colors.grey),
                    const SizedBox(width: 10),
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 3),
                    const Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: Colors.grey,
                    ),
                  ],
                ),

                if (type.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        type,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                  ),
                ],

                if (children.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 6,
                    runSpacing: 4,
                    children: children.map<Widget>((ch) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6A11CB).withOpacity(0.07),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF6A11CB).withOpacity(0.2),
                          ),
                        ),
                        child: Text(
                          ch['name'] ?? '',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF6A11CB),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                if (notes.isNotEmpty && notes != 'null') ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Text(
                      notes,
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===================== MICRO WIDGETS =====================

  Widget _loadingWidget() => const Center(
    child: Padding(
      padding: EdgeInsets.all(12),
      child: CircularProgressIndicator(strokeWidth: 2),
    ),
  );

  Widget _emptyHint(String msg) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(msg, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
  );
}
