import 'package:flutter/material.dart';

import '../../../../../services/auth_service.dart';

import '../home/home_screen.dart';
import '../children/children_list_screen.dart';
import '../children/child_details_screen.dart';
import 'package:college_project/core/enums/user_role.dart';
import 'register_child_screen.dart';
import '../psychologists/specialist_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ================= CONTROLLERS =================

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  // ================= LOGIN FUNCTION =================

  Future<void> login() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await AuthService.login(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // ================= SUCCESS =================

      if (response['status'] == true) {
        final user = response['data'];

        final String role = user['role'] ?? '';

        final String fullName = user['full_name'] ?? '';

        final int userId = int.tryParse(user['id'].toString()) ?? 0;

        final int familyId = int.tryParse(user['family_id'].toString()) ?? 0;

        final String familyName = user['family_name'] ?? '';

        final int childId = int.tryParse(user['child_id'].toString()) ?? 0;

        // ================= ADMIN =================

        if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(currentUserId: userId),
            ),
          );
        }
        // ================= FAMILY MANAGER =================
        else if (role == 'family_manager' || role == 'assistant') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ChildrenListScreen(
                familyId: familyId,
                familyName: familyName,
                isSpecialist: false,
                currentUserRole: role == 'assistant'
                    ? UserRole.assistant
                    : UserRole.familyManager,
                currentUserId: userId,
              ),
            ),
          );
        }
        // ================= SPECIALIST =================
        else if (role == 'specialist') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SpecialistDashboardScreen(
                specialistId: int.tryParse(user['id'].toString()) ?? 0,
                specialistName: fullName,
                specialistType: user['specialist_type'] ?? '',
                familyId: int.tryParse(user['family_id'].toString()) ?? 0,
                familyName: user['family_name'] ?? '',
              ),
            ),
          );
        }
        // ================= CHILD =================
        else if (role == 'child') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ChildDetailsScreen(
                childId: childId,
                childName: fullName,
                currentUserRole: UserRole.child,
                currentUserId: userId,
              ),
            ),
          );
        }
        // ================= UNKNOWN ROLE =================
        else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('صلاحية المستخدم غير معروفة')),
          );
        }
      }
      // ================= FAILED =================
      else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response['message'])));
      }
    }
    // ================= ERROR =================
    catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }

    setState(() {
      isLoading = false;
    });
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),

            child: Container(
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(30),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),

                    blurRadius: 20,
                  ),
                ],
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,

                children: [
                  // ================= LOGO =================
                  Container(
                    height: 100,
                    width: 100,

                    decoration: BoxDecoration(
                      shape: BoxShape.circle,

                      image: const DecorationImage(
                        image: AssetImage('assets/images/Logo.jpeg'),

                        fit: BoxFit.cover,
                      ),

                      border: Border.all(color: Colors.black12, width: 1),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ================= EMAIL =================
                  TextField(
                    controller: emailController,

                    decoration: InputDecoration(
                      hintText: 'Email',

                      prefixIcon: const Icon(Icons.person_outline),

                      filled: true,

                      fillColor: const Color(0xFFF0F2F5),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),

                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // ================= PASSWORD =================
                  TextField(
                    controller: passwordController,

                    obscureText: true,

                    decoration: InputDecoration(
                      hintText: 'Password',

                      prefixIcon: const Icon(Icons.lock_outline),

                      filled: true,

                      fillColor: const Color(0xFFF0F2F5),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),

                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ================= BUTTONS =================
                  Row(
                    children: [
                      // ===== LOGIN =====
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : login,

                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),

                                side: const BorderSide(color: Colors.black),
                              ),
                            ),

                            child: isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('LOGIN'),
                          ),
                        ),
                      ),

                      const SizedBox(width: 15),

                      // ===== REGISTER =====
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const RegisterChildScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                                side: const BorderSide(color: Colors.black),
                              ),
                            ),
                            child: const Text('REGISTER'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
