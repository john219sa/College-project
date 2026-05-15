import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// كلاس لتمثيل بيانات عضو الفريق
class TeamMember {
  final String name;
  final String role;
  final String imagePath;
  final String facebookUrl;
  final String email;

  TeamMember({
    required this.name,
    required this.role,
    required this.imagePath,
    required this.facebookUrl,
    required this.email,
  });
}

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  // دالة لفتح الروابط (تم تحسينها لدعم mailto و tel)
  Future<void> _openURL(String urlString) async {
    if (urlString.isEmpty) return;
    final Uri uri = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("خطأ في فتح الرابط: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xff1A237E);
    const Color darkerBlue = Color(0xff151D61);
    final List<TeamMember> teamMembers = [
      TeamMember(
        name: "مينا رضا",
        role: "أخصائي تخاطب",
        imagePath: 'assets/images/mina.jpg',
        facebookUrl: 'https://facebook.com/...',
        email: 'minareda70529714@gmail.com',
      ),
      TeamMember(
        name: "جاسر محمد",
        role: "أخصائي تعديل سلوك",
        imagePath: 'assets/images/gasser.jpg',
        facebookUrl: 'https://facebook.com/...',
        email: 'gaser8375@gmail.com',
      ),
      TeamMember(
        name: "جون صفوت",
        role: " أخصائي تنمية مهارات",
        imagePath: 'assets/images/john.jpg',
        facebookUrl: 'https://facebook.com/...',
        email: 'John219saf@gmail.com',
      ),
      TeamMember(
        name: "اسراء محمد ",
        role: "أخصائي نفسي",
        imagePath: 'assets/images/esraa.jpg',
        facebookUrl: '',
        email: '',
      ),
      TeamMember(
        name: "عمرو محمد",
        role: "أخصائي علاج طبيعي",
        imagePath: 'assets/images/amr.jpg',
        facebookUrl: 'https://facebook.com/...',
        email: 'amr.ismmail@gmail.com',
      ),
      TeamMember(
        name: "منه الله حسن",
        role: "أخصائي صعوبات تعلم",
        imagePath: 'assets/images/menna.jpg',
        facebookUrl: 'https://facebook.com/...',
        email: 'manona2512@gmail.com',
      ),
    ];
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9), // خلفية هادئة مريحة للعين
      appBar: AppBar(
        title: const Text(
          "عن المركز",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. الهيدر (صورة الفريق مع الطبقة الشفافة)
            _buildHeader(),

            const SizedBox(height: 30),

            // 2. القادة (بسنت وفاطمة) بنفس الستايل الدائري
            _buildTopLeaders(),

            const SizedBox(height: 40),

            // 3. شبكة الفريق (Grid) بخلفية زرقاء كما طلبتِ
            _buildTeamGrid(primaryBlue, darkerBlue, teamMembers),

            const SizedBox(height: 30),

            // 4. قسم التواصل والمعلومات
            _buildContactSection(primaryBlue),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- مكونات الصفحة (Widgets) ---

  Widget _buildHeader() {
    return Stack(
      children: [
        Container(
          height: 220,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                'https://images.unsplash.com/photo-1522071820081-009f0129c71c?q=80&w=2070',
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          height: 220,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
            ),
          ),
          alignment: Alignment.center,
          child: const Text(
            "فريق العمل والقيادة",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopLeaders() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _largeLeaderItem(
          "بسنت مجدي",
          "Creative Leader",
          'assets/images/bassant.jpg',
        ),
        _largeLeaderItem("فاطمة محمد", "Manager", 'assets/images/fatma.jpg'),
      ],
    );
  }

  Widget _largeLeaderItem(String name, String role, String assetPath) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: Color(0xff1A237E),
            shape: BoxShape.circle,
          ),
          child: CircleAvatar(
            radius: 45,
            backgroundImage: AssetImage(assetPath),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(role, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      ],
    );
  }

  Widget _buildTeamGrid(
    Color primaryBlue,
    Color darkerBlue,
    List<TeamMember> members,
  ) {
    return Container(
      width: double.infinity,
      color: primaryBlue,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        children: [
          const Text(
            "الأخصائيين والكوادر",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              childAspectRatio: 0.8,
            ),
            itemCount: members.length,
            itemBuilder: (context, index) =>
                _teamCard(darkerBlue, members[index]),
          ),
        ],
      ),
    );
  }

  Widget _teamCard(Color cardColor, TeamMember member) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 35,
            backgroundImage: AssetImage(member.imagePath),
          ),
          const SizedBox(height: 12),
          Text(
            member.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            member.role,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _socialIcon(Icons.facebook, () => _openURL(member.facebookUrl)),
              const SizedBox(width: 10),
              _socialIcon(
                Icons.email,
                () => _openURL('mailto:${member.email}'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _socialIcon(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Icon(icon, color: Colors.white70, size: 22),
    );
  }

  Widget _buildContactSection(Color primaryBlue) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _contactInfoTile(
            Icons.location_on,
            "موقعنا في برج العرب",
            "اضغط لفتح الخريطة",
            () => _openURL('https://maps.app.goo.gl/STcfctWvySmREHjB7'),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _contactActionBtn(
                  Icons.facebook,
                  "فيسبوك",
                  const Color(0xff1877F2),
                  () => _openURL('https://facebook.com/...'),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _contactActionBtn(
                  Icons.phone,
                  "اتصل بنا",
                  Colors.green,
                  () => _openURL('tel:+201278845667'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _contactInfoTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      onTap: onTap,
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      leading: CircleAvatar(
        backgroundColor: Colors.blue.withOpacity(0.1),
        child: Icon(icon, color: const Color(0xff1A237E)),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
    );
  }

  Widget _contactActionBtn(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
