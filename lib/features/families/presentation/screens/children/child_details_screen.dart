import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test/core/enums/user_role.dart';

class ChildDetailsScreen extends StatefulWidget {
  final int childId;

  final String childName;

  final UserRole currentUserRole;

  const ChildDetailsScreen({
    super.key,
    required this.childId,
    required this.childName,
    required this.currentUserRole,
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

  // ================= GET DATA =================

  Future<void> getChildDetails() async {
    try {
      final response = await http.get(
        Uri.parse(
          "http://192.168.1.2/api/children/get_child_details.php?child_id=${widget.childId}",
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
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    getChildDetails();
  }

  // ================= الصلاحيات =================

  bool get canEditTreatment =>
      widget.currentUserRole == UserRole.admin ||
      widget.currentUserRole == UserRole.familyManager ||
      widget.currentUserRole == UserRole.assistant ||
      widget.currentUserRole == UserRole.specialist;

  bool get canEditReports =>
      widget.currentUserRole == UserRole.admin ||
      widget.currentUserRole == UserRole.familyManager ||
      widget.currentUserRole == UserRole.assistant ||
      widget.currentUserRole == UserRole.specialist;

  bool get canAddExercises =>
      widget.currentUserRole == UserRole.admin ||
      widget.currentUserRole == UserRole.specialist ||
      widget.currentUserRole == UserRole.familyManager ||
      widget.currentUserRole == UserRole.assistant;

  bool get canAddComment => true;

  // ================= PICK PDF =================

  Future<void> pickPdfFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      String filePath = result.files.single.path!;

      print(filePath);

      // upload api here
    }
  }

  // ================= EDIT DIALOG =================

  void showEditDialog(String title, String value) {
    TextEditingController controller = TextEditingController(text: value);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),

          content: TextField(controller: controller),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('إلغاء'),
            ),

            ElevatedButton(
              onPressed: () {
                // update api here

                Navigator.pop(context);
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),

      floatingActionButton: canAddComment
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF2575FC),

              onPressed: () {},

              child: const Icon(Icons.add_comment),
            )
          : null,

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // ================= HEADER =================
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

                  // ================= BODY =================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),

                    child: Column(
                      children: [
                        // ================= INFO =================
                        _buildDetailCard(
                          title: 'المعلومات الأساسية',

                          icon: Icons.info_outline,

                          children: [
                            _buildInfoRow(
                              'السن:',

                              childData['age'].toString(),

                              onEdit: canEditTreatment
                                  ? () {
                                      showEditDialog(
                                        'تعديل السن',
                                        childData['age'].toString(),
                                      );
                                    }
                                  : null,
                            ),

                            _buildInfoRow(
                              'التشخيص:',

                              childData['diagnosis'] ?? '',

                              onEdit: canEditTreatment
                                  ? () {
                                      showEditDialog(
                                        'تعديل التشخيص',
                                        childData['diagnosis'] ?? '',
                                      );
                                    }
                                  : null,
                            ),
                          ],
                        ),

                        // ================= REPORTS =================
                        _buildDetailCard(
                          title: 'التقارير',

                          icon: Icons.analytics_outlined,

                          action: canEditReports
                              ? IconButton(
                                  onPressed: () {},

                                  icon: const Icon(Icons.edit),
                                )
                              : null,

                          children: reports.isEmpty
                              ? [const Text('لا توجد تقارير')]
                              : reports.map((report) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 10),

                                    child: Text(report['report_text']),
                                  );
                                }).toList(),
                        ),

                        // ================= TREATMENTS =================
                        _buildDetailCard(
                          title: 'الخطة العلاجية',

                          icon: Icons.healing,

                          color: Colors.orange,

                          action: canEditTreatment
                              ? IconButton(
                                  onPressed: () {},

                                  icon: const Icon(Icons.edit),
                                )
                              : null,

                          children: treatments.isEmpty
                              ? [const Text('لا يوجد علاج')]
                              : treatments.map((treatment) {
                                  return _buildBulletPoint(treatment['title']);
                                }).toList(),
                        ),

                        // ================= EXERCISES =================
                        _buildDetailCard(
                          title: 'التمارين',

                          icon: Icons.fitness_center,

                          color: Colors.deepPurple,

                          action: canAddExercises
                              ? IconButton(
                                  onPressed: () {},

                                  icon: const Icon(Icons.add),
                                )
                              : null,

                          children: exercises.isEmpty
                              ? [const Text('لا توجد تمارين')]
                              : exercises.map((exercise) {
                                  return _buildBulletPoint(exercise['title']);
                                }).toList(),
                        ),

                        // ================= SCANS =================
                        _buildDetailCard(
                          title: 'الأشعات',

                          icon: Icons.image,

                          color: Colors.teal,

                          action: canEditReports
                              ? IconButton(
                                  onPressed: () {
                                    pickPdfFile();
                                  },

                                  icon: const Icon(Icons.upload_file),
                                )
                              : null,

                          children: scans.isEmpty
                              ? [const Text('لا توجد أشعات')]
                              : scans.map((scan) {
                                  return _buildFileItem(scan['file_name']);
                                }).toList(),
                        ),

                        // ================= TESTS =================
                        _buildDetailCard(
                          title: 'التحاليل',

                          icon: Icons.science,

                          color: Colors.redAccent,

                          action: canEditReports
                              ? IconButton(
                                  onPressed: () {
                                    pickPdfFile();
                                  },

                                  icon: const Icon(Icons.upload),
                                )
                              : null,

                          children: tests.isEmpty
                              ? [const Text('لا توجد تحاليل')]
                              : tests.map((test) {
                                  return _buildFileItem(test['file_name']);
                                }).toList(),
                        ),

                        // ================= COMMENTS =================
                        _buildDetailCard(
                          title: 'التعليقات',

                          icon: Icons.comment_outlined,

                          color: Colors.green,

                          action: canAddComment
                              ? IconButton(
                                  onPressed: () {},

                                  icon: const Icon(Icons.add_comment),
                                )
                              : null,

                          children: comments.isEmpty
                              ? [const Text('لا توجد تعليقات')]
                              : comments.map((comment) {
                                  return _buildComment(
                                    comment['full_name'],

                                    comment['comment'],
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
    );
  }

  // ================= CARD =================

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

// ================= HEADER CLIPPER =================

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
