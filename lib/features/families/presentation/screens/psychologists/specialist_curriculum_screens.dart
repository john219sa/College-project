import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/constants/api_constants.dart';

// ════════════════════════════════════════════════════════════════
// STEP 1 — اختيار الأخصائيين
// ════════════════════════════════════════════════════════════════
class SpecialistSelectionScreen extends StatefulWidget {
  const SpecialistSelectionScreen({super.key});

  @override
  State<SpecialistSelectionScreen> createState() =>
      _SpecialistSelectionScreenState();
}

class _SpecialistSelectionScreenState extends State<SpecialistSelectionScreen> {
  bool isLoading = true;

  // بيانات الأخصائيين مجمّعة حسب التخصص
  Map<String, List<Map<String, dynamic>>> groupedSpecialists = {
    'speech': [],
    'psychologist': [],
    'behavior': [],
  };

  // الأخصائيين المحددين
  Set<int> selectedIds = {};

  // ألوان وأسماء كل تخصص
  final Map<String, Map<String, dynamic>> specialistMeta = {
    'speech': {
      'label': 'أخصائيو التخاطب',
      'color': const Color(0xFFFFF3E0),
      'border': const Color(0xFFFFB74D),
      'icon': Icons.record_voice_over,
      'iconColor': const Color(0xFFE65100),
    },
    'psychologist': {
      'label': 'أخصائيو النفس',
      'color': const Color(0xFFE8F5E9),
      'border': const Color(0xFF66BB6A),
      'icon': Icons.psychology,
      'iconColor': const Color(0xFF2E7D32),
    },
    'behavior': {
      'label': 'أخصائيو تعديل السلوك',
      'color': const Color(0xFFE3F2FD),
      'border': const Color(0xFF42A5F5),
      'icon': Icons.self_improvement,
      'iconColor': const Color(0xFF1565C0),
    },
  };

  @override
  void initState() {
    super.initState();
    _loadSpecialists();
  }

  Future<void> _loadSpecialists() async {
    try {
      final res = await http
          .get(
            Uri.parse(
              '${ApiConstants.baseUrl}/specialists/get_all_specialists.php',
            ),
          )
          .timeout(const Duration(seconds: 15));
      final data = jsonDecode(res.body);
      if (data['status'] == true) {
        final List list = data['data'];
        final grouped = {
          'speech': <Map<String, dynamic>>[],
          'psychologist': <Map<String, dynamic>>[],
          'behavior': <Map<String, dynamic>>[],
        };
        for (var sp in list) {
          final type = sp['specialist_type'] ?? '';
          if (grouped.containsKey(type)) {
            grouped[type]!.add(Map<String, dynamic>.from(sp));
          }
        }
        setState(() {
          groupedSpecialists = grouped;
          isLoading = false;
        });
      }
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  void _toggleAll(String type) {
    final ids = groupedSpecialists[type]!
        .map<int>((e) => e['id'] as int)
        .toSet();
    final allSelected = ids.every((id) => selectedIds.contains(id));
    setState(() {
      if (allSelected) {
        selectedIds.removeAll(ids);
      } else {
        selectedIds.addAll(ids);
      }
    });
  }

  void _toggleOne(int id) {
    setState(() {
      if (selectedIds.contains(id)) {
        selectedIds.remove(id);
      } else {
        selectedIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        title: const Text(
          'رفع المنهج',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ── Header ──────────────────────────────────
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
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
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6A11CB).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.group,
                          color: Color(0xFF6A11CB),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'اختر الأخصائيين',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'تم تحديد ${selectedIds.length} أخصائي',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Groups ──────────────────────────────────
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: specialistMeta.keys.map((type) {
                      final meta = specialistMeta[type]!;
                      final list = groupedSpecialists[type]!;
                      final allSel =
                          list.isNotEmpty &&
                          list.every(
                            (e) => selectedIds.contains(e['id'] as int),
                          );

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: meta['color'] as Color,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: meta['border'] as Color,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            // ── Group header ──
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  // تحديد الكل
                                  GestureDetector(
                                    onTap: list.isEmpty
                                        ? null
                                        : () => _toggleAll(type),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: allSel
                                            ? meta['border'] as Color
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: meta['border'] as Color,
                                        ),
                                      ),
                                      child: Text(
                                        allSel ? 'إلغاء الكل' : 'تحديد الكل',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: allSel
                                              ? Colors.white
                                              : meta['iconColor'] as Color,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  // اسم المجموعة
                                  Text(
                                    meta['label'] as String,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: meta['iconColor'] as Color,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    meta['icon'] as IconData,
                                    color: meta['iconColor'] as Color,
                                    size: 22,
                                  ),
                                ],
                              ),
                            ),

                            const Divider(height: 1),

                            // ── Specialist cards ──
                            list.isEmpty
                                ? Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Text(
                                      'لا يوجد أخصائيون',
                                      style: TextStyle(color: Colors.grey[500]),
                                    ),
                                  )
                                : Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: list.map((sp) {
                                      final id = sp['id'] as int;
                                      final selected = selectedIds.contains(id);
                                      return GestureDetector(
                                        onTap: () => _toggleOne(id),
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 200,
                                          ),
                                          margin: const EdgeInsets.only(
                                            bottom: 4,
                                            left: 8,
                                            right: 8,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: selected
                                                ? meta['border'] as Color
                                                : Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: meta['border'] as Color,
                                              width: selected ? 0 : 1,
                                            ),
                                            boxShadow: selected
                                                ? [
                                                    BoxShadow(
                                                      color:
                                                          (meta['border']
                                                                  as Color)
                                                              .withValues(
                                                                alpha: 0.3,
                                                              ),
                                                      blurRadius: 8,
                                                    ),
                                                  ]
                                                : [],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (selected)
                                                const Icon(
                                                  Icons.check_circle,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                              if (selected)
                                                const SizedBox(width: 6),
                                              Text(
                                                sp['full_name'] ?? '',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: selected
                                                      ? Colors.white
                                                      : Colors.black87,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // ── زرار رفع المنهج ─────────────────────────
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: selectedIds.isEmpty
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => UploadCurriculumScreen(
                                    selectedSpecialistIds: selectedIds.toList(),
                                  ),
                                ),
                              );
                            },
                      icon: const Icon(Icons.upload_file),
                      label: Text(
                        selectedIds.isEmpty
                            ? 'اختر أخصائياً أولاً'
                            : 'رفع المنهج للمحددين (${selectedIds.length})',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A11CB),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[300],
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// STEP 2 — رفع المنهج
// ════════════════════════════════════════════════════════════════
class UploadCurriculumScreen extends StatefulWidget {
  final List<int> selectedSpecialistIds;

  const UploadCurriculumScreen({
    super.key,
    required this.selectedSpecialistIds,
  });

  @override
  State<UploadCurriculumScreen> createState() => _UploadCurriculumScreenState();
}

class _UploadCurriculumScreenState extends State<UploadCurriculumScreen> {
  // ─── Controllers ────────────────────────────────────────
  final _commentController = TextEditingController();
  final _exerciseController = TextEditingController();
  final _treatmentController = TextEditingController();

  bool _isLoading = false;

  // ─── Files ──────────────────────────────────────────────
  List<PlatformFile> _pdfFiles = [];
  List<XFile> _imageFiles = [];
  String? _videoPath;

  @override
  void dispose() {
    _commentController.dispose();
    _exerciseController.dispose();
    _treatmentController.dispose();
    super.dispose();
  }

  // ─── Pick PDF ───────────────────────────────────────────
  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );
    if (result != null) {
      setState(() => _pdfFiles = result.files);
    }
  }

  // ─── Pick Images ────────────────────────────────────────
  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() => _imageFiles = images);
    }
  }

  // ─── Pick Video ─────────────────────────────────────────
  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final video = await picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() => _videoPath = video.path);
    }
  }

  // ─── Upload ─────────────────────────────────────────────
  Future<void> _upload() async {
    if (_commentController.text.trim().isEmpty &&
        _exerciseController.text.trim().isEmpty &&
        _treatmentController.text.trim().isEmpty &&
        _pdfFiles.isEmpty &&
        _imageFiles.isEmpty &&
        _videoPath == null) {
      _snack('يرجى إدخال محتوى واحد على الأقل', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}/curriculum/upload_curriculum.php',
      );
      final request = http.MultipartRequest('POST', uri);

      // Text fields
      request.fields['specialist_ids'] = jsonEncode(
        widget.selectedSpecialistIds,
      );
      request.fields['comment'] = _commentController.text.trim();
      request.fields['exercise'] = _exerciseController.text.trim();
      request.fields['treatment'] = _treatmentController.text.trim();

      // PDFs
      for (final pdf in _pdfFiles) {
        if (pdf.path != null) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'pdfs[]',
              pdf.path!,
              filename: pdf.name,
            ),
          );
        }
      }

      // Images
      for (final img in _imageFiles) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'images[]',
            img.path,
            filename: img.name,
          ),
        );
      }

      // Video
      if (_videoPath != null) {
        request.files.add(
          await http.MultipartFile.fromPath('video', _videoPath!),
        );
      }

      final streamed = await request.send().timeout(
        const Duration(seconds: 60),
      );
      final response = await http.Response.fromStream(streamed);
      final data = jsonDecode(response.body);

      if (data['status'] == true) {
        _snack('تم رفع المنهج بنجاح ✓', isError: false);
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) Navigator.pop(context);
      } else {
        _snack(data['message'] ?? 'حدث خطأ', isError: true);
      }
    } catch (e) {
      _snack('تعذر الاتصال بالخادم', isError: true);
      debugPrint('Upload error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _snack(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
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
        title: const Text(
          'رفع المنهج',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF6A11CB).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${widget.selectedSpecialistIds.length} أخصائي',
                  style: const TextStyle(
                    color: Color(0xFF6A11CB),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── التعليقات ──────────────────────────────────
            _buildTextSection(
              title: 'التعليقات',
              hint: 'اكتب تعليقك هنا...',
              controller: _commentController,
              icon: Icons.comment_outlined,
              color: const Color(0xFF6A11CB),
            ),
            const SizedBox(height: 16),

            // ── التمارين ───────────────────────────────────
            _buildTextSection(
              title: 'التمارين',
              hint: 'اكتب تفاصيل التمرين...',
              controller: _exerciseController,
              icon: Icons.fitness_center,
              color: Colors.deepOrange,
            ),
            const SizedBox(height: 16),

            // ── العلاج ─────────────────────────────────────
            _buildTextSection(
              title: 'الخطة العلاجية',
              hint: 'اكتب الخطة العلاجية...',
              controller: _treatmentController,
              icon: Icons.healing,
              color: Colors.teal,
            ),
            const SizedBox(height: 16),

            // ── PDF ────────────────────────────────────────
            _buildFileSection(
              title: 'رفع PDF',
              icon: Icons.picture_as_pdf,
              color: Colors.red,
              subtitle: _pdfFiles.isEmpty
                  ? 'لم يتم اختيار ملفات'
                  : '${_pdfFiles.length} ملف PDF',
              onTap: _pickPdf,
              child: _pdfFiles.isEmpty
                  ? null
                  : Column(
                      children: _pdfFiles
                          .map(
                            (f) => _fileChip(
                              f.name,
                              Icons.picture_as_pdf,
                              Colors.red,
                            ),
                          )
                          .toList(),
                    ),
            ),
            const SizedBox(height: 16),

            // ── صور ────────────────────────────────────────
            _buildFileSection(
              title: 'رفع صور',
              icon: Icons.image_outlined,
              color: Colors.blue,
              subtitle: _imageFiles.isEmpty
                  ? 'لم يتم اختيار صور'
                  : '${_imageFiles.length} صورة',
              onTap: _pickImages,
              child: _imageFiles.isEmpty
                  ? null
                  : Wrap(
                      spacing: 8,
                      children: _imageFiles
                          .map(
                            (f) => _fileChip(f.name, Icons.image, Colors.blue),
                          )
                          .toList(),
                    ),
            ),
            const SizedBox(height: 16),

            // ── فيديو ──────────────────────────────────────
            _buildFileSection(
              title: 'رفع فيديو',
              icon: Icons.videocam_outlined,
              color: Colors.purple,
              subtitle: _videoPath == null
                  ? 'لم يتم اختيار فيديو'
                  : _videoPath!.split('/').last,
              onTap: _pickVideo,
            ),
            const SizedBox(height: 30),

            // ── زرار الرفع ─────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _upload,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.cloud_upload),
                label: Text(_isLoading ? 'جاري الرفع...' : 'رفع المنهج'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A11CB),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ─── Widgets ────────────────────────────────────────────

  Widget _buildTextSection({
    required String title,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    required Color color,
  }) {
    return Container(
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
          Row(
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
          ),
          const Divider(height: 20),
          TextField(
            controller: controller,
            textAlign: TextAlign.right,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.grey.withValues(alpha: 0.2),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.grey.withValues(alpha: 0.1),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileSection({
    required String title,
    required IconData icon,
    required Color color,
    required String subtitle,
    required VoidCallback onTap,
    Widget? child,
  }) {
    return Container(
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
          Row(
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
          ),
          const Divider(height: 20),
          if (child != null) ...[child, const SizedBox(height: 10)],
          OutlinedButton.icon(
            onPressed: onTap,
            icon: Icon(Icons.attach_file, color: color),
            label: Text(subtitle, style: TextStyle(color: color)),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: color.withValues(alpha: 0.4)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fileChip(String name, IconData icon, Color color) {
    final short = name.length > 25 ? '${name.substring(0, 22)}...' : name;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(short, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }
}
