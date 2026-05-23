import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../../core/constants/api_constants.dart';
import 'login_screen.dart';

class RegisterChildScreen extends StatefulWidget {
  final int? createdBy;
  final int? familyId;

  const RegisterChildScreen({super.key, this.createdBy, this.familyId});

  @override
  State<RegisterChildScreen> createState() => _RegisterChildScreenState();
}

class _RegisterChildScreenState extends State<RegisterChildScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  String selectedService = 'جلسات تكامل';
  final List<String> serviceOptions = [
    'جلسات تكامل',
    'اختبار ذكاء',
    'تعديل سلوك',
    'تخاطب',
    'تنمية مهارات',
    'أكاديمي',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _registerChild() async {
    if (_nameController.text.trim().isEmpty) {
      _showSnackBar('يرجى إدخال اسم الطفل', isError: true);
      return;
    }
    if (_phoneController.text.trim().isEmpty) {
      _showSnackBar('يرجى إدخال رقم الهاتف', isError: true);
      return;
    }
    if (_usernameController.text.trim().isEmpty) {
      _showSnackBar('يرجى إدخال اسم المستخدم', isError: true);
      return;
    }
    if (_passwordController.text.trim().isEmpty) {
      _showSnackBar('يرجى إدخال كلمة المرور', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http
          .post(
            Uri.parse('${ApiConstants.baseUrl}/children/register_child.php'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': _nameController.text.trim(),
              'age': int.tryParse(_ageController.text.trim()) ?? 0,
              'phone': _phoneController.text.trim(),
              'service_type': selectedService,
              'email': _usernameController.text.trim(),
              'password': _passwordController.text.trim(),
              'created_by': widget.createdBy ?? 0,
              'family_id': widget.familyId ?? 0,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (data['status'] == true) {
        _showSnackBar(
          'تم التسجيل بنجاح — في انتظار موافقة الإدارة',
          isError: false,
        );
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      } else {
        _showSnackBar(
          data['message'] ?? 'حدث خطأ، حاول مرة أخرى',
          isError: true,
        );
      }
    } catch (e) {
      _showSnackBar('تعذر الاتصال بالخادم', isError: true);
      debugPrint('RegisterChild error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text(
          'تسجيل حالة جديدة',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blueAccent.withValues(alpha: 0.1),
              child: const Icon(
                Icons.person_add_alt_1,
                color: Colors.blueAccent,
                size: 40,
              ),
            ),
            const SizedBox(height: 25),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'بيانات الطفل الأساسية',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const Divider(height: 30),
                  _buildTextField(
                    label: 'اسم الطفل',
                    hint: 'أدخل الاسم الثلاثي',
                    controller: _nameController,
                    icon: Icons.child_care,
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'رقم الهاتف',
                          hint: 'رقم ولي الأمر',
                          controller: _phoneController,
                          icon: Icons.phone_android,
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildTextField(
                          label: 'العمر',
                          hint: 'مثال: 6',
                          controller: _ageController,
                          icon: Icons.calendar_today,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'نوع الخدمة المطلوبة:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildDropdown(),
                  const SizedBox(height: 30),
                  const Text(
                    'بيانات الحساب (في حالة القبول)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const Divider(height: 30),
                  _buildTextField(
                    label: 'اسم المستخدم (User Name)',
                    hint: 'مثال: ahmed_2024',
                    controller: _usernameController,
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 15),
                  _buildTextField(
                    label: 'كلمة المرور (Password)',
                    hint: 'أدخل كلمة مرور قوية',
                    controller: _passwordController,
                    icon: Icons.lock_outline,
                    isPassword: true,
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _registerChild,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 0,
                        disabledBackgroundColor: Colors.blueAccent.withValues(
                          alpha: 0.5,
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'إتمام التسجيل',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: selectedService,
          icon: const Icon(
            Icons.arrow_drop_down_circle_outlined,
            color: Colors.blueAccent,
          ),
          items: serviceOptions.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(value),
              ),
            );
          }).toList(),
          onChanged: _isLoading
              ? null
              : (newValue) => setState(() => selectedService = newValue!),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          textAlign: TextAlign.right,
          keyboardType: keyboardType,
          obscureText: isPassword ? !_isPasswordVisible : false,
          enabled: !_isLoading,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () => setState(
                      () => _isPasswordVisible = !_isPasswordVisible,
                    ),
                  )
                : Icon(icon, color: Colors.blueAccent, size: 20),
            suffixIcon: isPassword
                ? Icon(icon, color: Colors.blueAccent, size: 20)
                : null,
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
            ),
          ),
        ),
      ],
    );
  }
}
