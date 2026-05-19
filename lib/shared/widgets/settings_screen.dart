import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'settings_provider.dart'; // تأكدي أن مسار الملف صحيح حسب ترتيب الفولدرات عندك

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ربط الصفحة بالـ Provider للاستماع والتعديل على حالة التطبيق بالكامل
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      backgroundColor: settingsProvider.isDarkMode
          ? const Color(0xFF121212)
          : const Color(0xFFF4F7FA),
      appBar: AppBar(
        title: const Text(
          'إعدادات النظام',
          style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: settingsProvider.isDarkMode
            ? Colors.white
            : Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // ١. قسم الحساب والملف الشخصي
            _buildSectionTitle('إعدادات الحساب والملف الشخصي'),
            _buildSectionContainer(
              isDarkMode: settingsProvider.isDarkMode,
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 16,
                    color: Colors.grey,
                  ),
                  title: Text(
                    'م. جون صفوت',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: settingsProvider.isDarkMode
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                  subtitle: const Text(
                    'تعديل الاسم، البريد، ورقم الهاتف',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  trailing: const CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(0xFF2575FC),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundImage: AssetImage('assets/images/Logo.jpeg'),
                    ),
                  ),
                  onTap: () {
                    // هنا يتم الانتقال لصفحة تعديل البيانات الشخصية
                  },
                ),
                const Divider(height: 20, indent: 15, endIndent: 15),
                _buildClickableSettingItem(
                  title: 'تغيير كلمة المرور',
                  subtitle: 'تحديث الرمز السري لتأمين الحساب',
                  icon: Icons.lock_reset_rounded,
                  iconColor: Colors.orange,
                  isDarkMode: settingsProvider.isDarkMode,
                  onTap: () {
                    // هنا نفتح Dialog أو صفحة لتغيير الباسورد
                  },
                ),
              ],
            ),

            const SizedBox(height: 25),
            // ٢. قسم المظهر والواجهة (UI & Theme) مرتبطة بالـ Provider
            _buildSectionTitle('المظهر والواجهة (UI & Theme)'),
            _buildSectionContainer(
              isDarkMode: settingsProvider.isDarkMode,
              children: [
                _buildSwitchSettingItem(
                  title: 'الوضع الليلي (Dark Mode)',
                  subtitle: 'التحويل بين المظهر الفاتح والمظلم',
                  icon: Icons.dark_mode_rounded,
                  iconColor: Colors.purple,
                  value: settingsProvider.isDarkMode,
                  onChanged: (val) {
                    settingsProvider.toggleTheme(
                      val,
                    ); // تحديث المظهر في التطبيق كله فوراً
                  },
                ),
                const Divider(height: 20, indent: 15, endIndent: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            settingsProvider.fontSizeMultiplier == 1.0
                                ? 'طبيعي'
                                : settingsProvider.fontSizeMultiplier == 1.2
                                ? 'متوسط'
                                : 'كبير',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2575FC),
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                'حجم الخط (Font Size)',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: settingsProvider.isDarkMode
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Icon(
                                Icons.format_size_rounded,
                                color: Colors.blue,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Slider(
                      value: settingsProvider.fontSizeMultiplier,
                      min: 1.0,
                      max: 1.4,
                      divisions: 2,
                      activeColor: const Color(0xFF2575FC),
                      inactiveColor: Colors.blue.withOpacity(0.1),
                      onChanged: (val) {
                        settingsProvider.updateFontSize(
                          val,
                        ); // تحديث حجم الخط في التطبيق كله فوراً
                      },
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 25),
            // ٣. قسم إعدادات النظام ومنع التعارضات (يمكنك لاحقاً ربط قيمها بالـ Provider أيضاً)
            _buildSectionTitle('إعدادات النظام والتحكم الذكي'),
            _buildSectionContainer(
              isDarkMode: settingsProvider.isDarkMode,
              children: [
                _buildDropdownSettingItem(
                  title: 'المدة الافتراضية للجلسة',
                  subtitle: 'تُستخدم لحساب التعارضات تلقائياً',
                  icon: Icons.hourglass_top_rounded,
                  iconColor: Colors.teal,
                  isDarkMode: settingsProvider.isDarkMode,
                  currentValue:
                      '٤٥ دقيقة', // قيمة تجريبية ثابتة أو اربطيها بمتغير في الـ Provider
                  items: ['٣٠ دقيقة', '٤٥ دقيقة', 'ساعة', 'ساعة ونصف'],
                  onChanged: (String? newValue) {
                    // كود التحديث عند الاختيار
                  },
                ),
                const Divider(height: 20, indent: 15, endIndent: 15),
                _buildClickableSettingItem(
                  title: 'مواعيد بداية العمل بالمركز',
                  subtitle: 'الوقت الافتراضي: ٠٩:٠٠ ص',
                  icon: Icons.wb_twighlight,
                  iconColor: Colors.amber,
                  isDarkMode: settingsProvider.isDarkMode,
                  onTap: () async {
                    await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                  },
                ),
                const Divider(height: 20, indent: 15, endIndent: 15),
                _buildClickableSettingItem(
                  title: 'مواعيد نهاية العمل بالمركز',
                  subtitle: 'الوقت الافتراضي: ١٠:٠٠ م',
                  icon: Icons.nightlight_round,
                  iconColor: Colors.indigo,
                  isDarkMode: settingsProvider.isDarkMode,
                  onTap: () async {
                    await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- الودجت المساعدة المعززة لدعم الـ Dark Mode وحجم الخط تلقائياً ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }

  Widget _buildSectionContainer({
    required List<Widget> children,
    required bool isDarkMode,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildClickableSettingItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: const Icon(
        Icons.arrow_back_ios_new_rounded,
        size: 14,
        color: Colors.grey,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 11, color: Colors.grey),
      ),
      trailing: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      onTap: onTap,
    );
  }

  Widget _buildSwitchSettingItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF2575FC),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: value ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 11, color: Colors.grey),
      ),
      trailing: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
    );
  }

  Widget _buildDropdownSettingItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isDarkMode,
    required String currentValue,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return ListTile(
      leading: DropdownButton<String>(
        value: currentValue,
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
        underline: const SizedBox(),
        dropdownColor: isDarkMode ? const Color(0xFF2E2E2E) : Colors.white,
        elevation: 2,
        style: const TextStyle(
          fontFamily: 'Cairo',
          color: Color(0xFF2575FC),
          fontWeight: FontWeight.bold,
        ),
        onChanged: onChanged,
        items: items.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
          );
        }).toList(),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 11, color: Colors.grey),
      ),
      trailing: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
    );
  }
}
