import 'dart:convert';
import '../../../../../core/constants/api_constants.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:college_project/core/enums/user_role.dart';

class ChildDetailsScreen extends StatefulWidget {
  final int childId;
  final String childName;
  final UserRole currentUserRole;
  final int currentUserId; // ← مطلوب لإضافة التعليقات والتقارير

  const ChildDetailsScreen({
    super.key,
    required this.childId,
    required this.childName,
    required this.currentUserRole,
    required this.currentUserId,
  });

  @override
  State<ChildDetailsScreen> createState() => _ChildDetailsScreenState();
}

class _ChildDetailsScreenState extends State<ChildDetailsScreen> {
  bool isLoading = true;

  Map childData = {};
  List treatments = [];
  List exercises = [];
  List reports = [];
  List comments = [];
  List scans = [];
  List tests = [];

  // ===================== GET DATA =====================

  Future<void> getChildDetails() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse(
          "${ApiConstants.baseUrl}/children/get_child_details.php?child_id=${widget.childId}",
        ),
      );
      final data = jsonDecode(response.body);
      if (data['status'] == true) {
        setState(() {
          childData = data['child'];
          treatments = data['treatments'];
          exercises = data['exercises'];
          reports = data['reports'];
          comments = data['comments'];
          scans = data['scans'];
          tests = data['tests'];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    getChildDetails();
  }

  // ===================== PERMISSIONS =====================

  bool get canEdit =>
      widget.currentUserRole == UserRole.admin ||
      widget.currentUserRole == UserRole.familyManager ||
      widget.currentUserRole == UserRole.assistant ||
      widget.currentUserRole == UserRole.specialist;

  bool get canAddComment => true;

  // ===================== SNACKBAR =====================

  void _showSnack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? Colors.red : Colors.green,
      ),
    );
  }

  // ===================== UPDATE CHILD =====================

  Future<void> updateChild(String field, String value) async {
    try {
      final Map<String, dynamic> body = {'child_id': widget.childId};
      if (field == 'age') body['age'] = int.tryParse(value) ?? 0;
      if (field == 'diagnosis') body['diagnosis'] = value;
      if (field == 'name') body['name'] = value;

      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/children/update_child.php"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      final data = jsonDecode(response.body);
      if (data['status'] == true) {
        _showSnack('تم التعديل بنجاح');
        getChildDetails();
      } else {
        _showSnack(data['message'] ?? 'فشل التعديل', error: true);
      }
    } catch (e) {
      _showSnack('خطأ: $e', error: true);
    }
  }

  // ===================== ADD COMMENT =====================

  Future<void> addComment(String comment) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/comments/add_comment.php"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'child_id': widget.childId,
          'user_id': widget.currentUserId,
          'comment': comment,
        }),
      );
      final data = jsonDecode(response.body);
      if (data['status'] == true) {
        _showSnack('تم إضافة التعليق');
        getChildDetails();
      } else {
        _showSnack(data['message'] ?? 'فشل', error: true);
      }
    } catch (e) {
      _showSnack('خطأ: $e', error: true);
    }
  }

  // ===================== ADD REPORT =====================

  Future<void> addReport(String reportText, String progressLevel) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/reports/add_report.php"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'child_id': widget.childId,
          'created_by': widget.currentUserId,
          'report_text': reportText,
          'progress_level': progressLevel,
        }),
      );
      final data = jsonDecode(response.body);
      if (data['status'] == true) {
        _showSnack('تم إضافة التقرير');
        getChildDetails();
      } else {
        _showSnack(data['message'] ?? 'فشل', error: true);
      }
    } catch (e) {
      _showSnack('خطأ: $e', error: true);
    }
  }

  // ===================== ADD TREATMENT =====================

  Future<void> addTreatment(String title, String description) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/treatments/add_treatment.php"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'child_id': widget.childId,
          'created_by': widget.currentUserId,
          'title': title,
          'description': description,
        }),
      );
      final data = jsonDecode(response.body);
      if (data['status'] == true) {
        _showSnack('تم إضافة الخطة العلاجية');
        getChildDetails();
      } else {
        _showSnack(data['message'] ?? 'فشل', error: true);
      }
    } catch (e) {
      _showSnack('خطأ: $e', error: true);
    }
  }

  // ===================== ADD EXERCISE =====================

  Future<void> addExercise(String title, String instructions) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/exercises/add_exercise.php"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'child_id': widget.childId,
          'created_by': widget.currentUserId,
          'title': title,
          'instructions': instructions,
        }),
      );
      final data = jsonDecode(response.body);
      if (data['status'] == true) {
        _showSnack('تم إضافة التمرين');
        getChildDetails();
      } else {
        _showSnack(data['message'] ?? 'فشل', error: true);
      }
    } catch (e) {
      _showSnack('خطأ: $e', error: true);
    }
  }

  // ===================== PICK PDF =====================

  Future<void> pickPdfFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      String filePath = result.files.single.path!;
      // TODO: رفع الملف للـ API
      print(filePath);
    }
  }

  // ===================== DIALOGS =====================

  /// ديالوج تعديل حقل واحد (السن أو التشخيص)
  void showEditDialog(String title, String value, String field) {
    final controller = TextEditingController(text: value);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: field == 'age'
              ? TextInputType.number
              : TextInputType.text,
          decoration: InputDecoration(hintText: title),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              updateChild(field, controller.text.trim());
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  /// ديالوج إضافة تعليق
  void showAddCommentDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة تعليق'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'اكتب تعليقك هنا...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              addComment(controller.text.trim());
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  /// ديالوج إضافة تقرير
  void showAddReportDialog() {
    final reportController = TextEditingController();
    final progressController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة تقرير'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: reportController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'نص التقرير',
                hintText: 'اكتب التقرير...',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: progressController,
              decoration: const InputDecoration(
                labelText: 'مستوى التقدم',
                hintText: 'مثال: جيد / ممتاز / ضعيف',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reportController.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              addReport(
                reportController.text.trim(),
                progressController.text.trim(),
              );
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  /// ديالوج إضافة خطة علاجية
  void showAddTreatmentDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة خطة علاجية'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'العنوان *'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descController,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'الوصف'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              addTreatment(
                titleController.text.trim(),
                descController.text.trim(),
              );
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  /// ديالوج إضافة تمرين
  void showAddExerciseDialog() {
    final titleController = TextEditingController();
    final instructionsController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة تمرين'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'عنوان التمرين *'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: instructionsController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'التعليمات'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              addExercise(
                titleController.text.trim(),
                instructionsController.text.trim(),
              );
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  // ===================== BUILD =====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      floatingActionButton: canAddComment
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF2575FC),
              onPressed: showAddCommentDialog,
              child: const Icon(Icons.add_comment),
            )
          : null,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: getChildDetails,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // ============ HEADER ============
                    Stack(
                      children: [
                        ClipPath(
                          clipper: HeaderClipper(),
                          child: Container(
                            height: 300,
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                        ),
                        SafeArea(
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.topRight,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ),
                              Center(
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 4,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: const CircleAvatar(
                                    radius: 60,
                                    backgroundColor: Colors.white24,
                                    child: Icon(
                                      Icons.face_retouching_natural,
                                      size: 70,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              Text(
                                widget.childName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // ============ BODY ============
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          // ---- المعلومات الأساسية ----
                          _buildDetailCard(
                            title: 'المعلومات الأساسية',
                            icon: Icons.info_outline,
                            children: [
                              _buildInfoRow(
                                'السن:',
                                childData['age']?.toString() ?? '-',
                                onEdit: canEdit
                                    ? () => showEditDialog(
                                        'تعديل السن',
                                        childData['age']?.toString() ?? '',
                                        'age',
                                      )
                                    : null,
                              ),
                              _buildInfoRow(
                                'التشخيص:',
                                childData['diagnosis'] ?? '-',
                                onEdit: canEdit
                                    ? () => showEditDialog(
                                        'تعديل التشخيص',
                                        childData['diagnosis'] ?? '',
                                        'diagnosis',
                                      )
                                    : null,
                              ),
                            ],
                          ),

                          // ---- التقارير ----
                          _buildDetailCard(
                            title: 'التقارير',
                            icon: Icons.analytics_outlined,
                            action: canEdit
                                ? IconButton(
                                    onPressed: showAddReportDialog,
                                    icon: const Icon(Icons.add),
                                  )
                                : null,
                            children: reports.isEmpty
                                ? [const Text('لا توجد تقارير')]
                                : reports.map<Widget>((report) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 10,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(report['report_text'] ?? ''),
                                          if (report['progress_level'] != null)
                                            Text(
                                              'المستوى: ${report['progress_level']}',
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12,
                                              ),
                                            ),
                                          const Divider(),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                          ),

                          // ---- الخطة العلاجية ----
                          _buildDetailCard(
                            title: 'الخطة العلاجية',
                            icon: Icons.healing,
                            color: Colors.orange,
                            action: canEdit
                                ? IconButton(
                                    onPressed: showAddTreatmentDialog,
                                    icon: const Icon(Icons.add),
                                  )
                                : null,
                            children: treatments.isEmpty
                                ? [const Text('لا يوجد علاج')]
                                : treatments.map<Widget>((treatment) {
                                    return _buildBulletPoint(
                                      treatment['title'] ?? '',
                                    );
                                  }).toList(),
                          ),

                          // ---- التمارين ----
                          _buildDetailCard(
                            title: 'التمارين',
                            icon: Icons.fitness_center,
                            color: Colors.deepPurple,
                            action: canEdit
                                ? IconButton(
                                    onPressed: showAddExerciseDialog,
                                    icon: const Icon(Icons.add),
                                  )
                                : null,
                            children: exercises.isEmpty
                                ? [const Text('لا توجد تمارين')]
                                : exercises.map<Widget>((exercise) {
                                    return _buildBulletPoint(
                                      exercise['title'] ?? '',
                                    );
                                  }).toList(),
                          ),

                          // ---- الأشعات ----
                          _buildDetailCard(
                            title: 'الأشعات',
                            icon: Icons.image,
                            color: Colors.teal,
                            action: canEdit
                                ? IconButton(
                                    onPressed: pickPdfFile,
                                    icon: const Icon(Icons.upload_file),
                                  )
                                : null,
                            children: scans.isEmpty
                                ? [const Text('لا توجد أشعات')]
                                : scans.map<Widget>((scan) {
                                    return _buildFileItem(
                                      scan['file_name'] ?? '',
                                    );
                                  }).toList(),
                          ),

                          // ---- التحاليل ----
                          _buildDetailCard(
                            title: 'التحاليل',
                            icon: Icons.science,
                            color: Colors.redAccent,
                            action: canEdit
                                ? IconButton(
                                    onPressed: pickPdfFile,
                                    icon: const Icon(Icons.upload),
                                  )
                                : null,
                            children: tests.isEmpty
                                ? [const Text('لا توجد تحاليل')]
                                : tests.map<Widget>((test) {
                                    return _buildFileItem(
                                      test['file_name'] ?? '',
                                    );
                                  }).toList(),
                          ),

                          // ---- التعليقات ----
                          _buildDetailCard(
                            title: 'التعليقات',
                            icon: Icons.comment_outlined,
                            color: Colors.green,
                            action: IconButton(
                              onPressed: showAddCommentDialog,
                              icon: const Icon(Icons.add_comment),
                            ),
                            children: comments.isEmpty
                                ? [const Text('لا توجد تعليقات')]
                                : comments.map<Widget>((comment) {
                                    return _buildComment(
                                      comment['full_name'] ?? 'مجهول',
                                      comment['comment'] ?? '',
                                    );
                                  }).toList(),
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // ===================== WIDGETS =====================

  Widget _buildDetailCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    Color color = const Color(0xFF6A11CB),
    Widget? action,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
              if (action != null) action,
            ],
          ),
          const Divider(height: 25),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {VoidCallback? onEdit}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
          if (onEdit != null)
            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
            ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildComment(String author, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            author,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 5),
          Text(text),
        ],
      ),
    );
  }

  Widget _buildFileItem(String fileName) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
      title: Text(fileName),
      trailing: IconButton(onPressed: () {}, icon: const Icon(Icons.download)),
    );
  }
}

// ===================== HEADER CLIPPER =====================

class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 60,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
