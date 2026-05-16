import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../../core/constants/api_constants.dart';
import '../psychologists/psychologist_screen.dart';
import 'child_details_screen.dart';
import 'package:college_project/core/enums/user_role.dart';

class ChildrenListScreen extends StatefulWidget {
  final int familyId;

  final String familyName;

  final bool isSpecialist;

  final int specialistId;

  const ChildrenListScreen({
    super.key,
    required this.familyId,
    required this.familyName,
    this.isSpecialist = false,
    this.specialistId = 0,
  });

  @override
  State<ChildrenListScreen> createState() => _ChildrenListScreenState();
}

class _ChildrenListScreenState extends State<ChildrenListScreen> {
  bool isLoading = true;

  List children = [];

  // ================= GET CHILDREN =================

  Future<void> getChildren() async {
    try {
      String url = '';

      // ================= SPECIALIST =================

      if (widget.isSpecialist) {
        url =
            "${ApiConstants.baseUrl}/children/get_specialist_children.php?specialist_id=${widget.specialistId}";
      }
      // ================= FAMILY =================
      else {
        url =
            "${ApiConstants.baseUrl}/children/get_children.php?family_id=${widget.familyId}";
      }

      final response = await http.get(Uri.parse(url));

      final data = jsonDecode(response.body);

      if (data['status'] == true) {
        setState(() {
          children = data['data'];

          isLoading = false;
        });
      } else {
        setState(() {
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
    getChildren();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),

      appBar: AppBar(
        title: Text(widget.familyName),

        centerTitle: true,

        backgroundColor: Colors.white,
      ),

      body: Column(
        children: [
          // ================= SPECIALISTS =================
          Container(
            width: double.infinity,

            margin: const EdgeInsets.all(15),

            padding: const EdgeInsets.all(20),

            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius: BorderRadius.circular(20),

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),

                  blurRadius: 10,
                ),
              ],
            ),

            child: Column(
              children: [
                const Text(
                  'الأخصائيين المسؤولين',

                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.blueAccent,
                  ),
                ),

                const SizedBox(height: 15),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    _buildSpecialistButton(
                      context,

                      'أخصائي تخاطب',

                      Icons.record_voice_over,

                      onTap: () {},
                    ),

                    const SizedBox(width: 20),

                    _buildSpecialistButton(
                      context,

                      'أخصائي نفسي',

                      Icons.psychology,

                      onTap: () {
                        Navigator.push(
                          context,

                          MaterialPageRoute(
                            builder: (context) => const PsychologistScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ================= SEARCH =================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),

            child: TextField(
              textAlign: TextAlign.right,

              decoration: InputDecoration(
                hintText: 'ابحث عن اسم الطفل...',

                prefixIcon: const Icon(Icons.search),

                filled: true,

                fillColor: Colors.white,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),

                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ================= LIST =================
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: children.length,

                    itemBuilder: (context, index) {
                      final child = children[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 5,
                        ),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),

                        child: ListTile(
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),

                          leading: const CircleAvatar(
                            backgroundColor: Colors.redAccent,

                            child: Icon(Icons.child_care),
                          ),

                          title: Text(
                            child['name'],
                            textAlign: TextAlign.right,
                          ),

                          subtitle: const Text(
                            'اضغط لعرض التفاصيل',
                            textAlign: TextAlign.right,
                          ),

                          onTap: () {
                            Navigator.push(
                              context,

                              MaterialPageRoute(
                                builder: (context) => ChildDetailsScreen(
                                  childId: int.parse(child['id']),
                                  childName: child['name'],
                                  currentUserRole: UserRole.specialist,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ================= SPECIALIST BUTTON =================

  Widget _buildSpecialistButton(
    BuildContext context,

    String label,

    IconData icon, {

    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,

      child: Column(
        children: [
          CircleAvatar(
            radius: 25,

            backgroundColor: Colors.blue.withOpacity(0.1),

            child: Icon(icon),
          ),

          const SizedBox(height: 5),

          Text(label),
        ],
      ),
    );
  }
}
