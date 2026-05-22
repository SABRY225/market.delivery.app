import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/locale_controller.dart';

class SettingsLanguageScreen extends StatelessWidget {
  const SettingsLanguageScreen({super.key});

  static const Color primaryColor = Color(0xFFFF5722); 
  static const Color textColor = Color(0xFF1E293B);    
  static const Color iconColor = Color(0xFF64748B);    
  static const Color backgroundColor = Color.fromARGB(255, 238, 236, 236);

  @override
  Widget build(BuildContext context) {
    final LocaleController controller = Get.find();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text("app_language".tr, style: const TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: textColor),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "choose_preferred_lang".tr, 
              style: const TextStyle(color: iconColor, fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 25),
            
            _buildLanguageCard(
              title: "العربية",
              subtitle: "Arabic",
              flag: "🇯🇴",
              isSelected: Get.locale?.languageCode == 'ar',
              onTap: () => controller.changeLang("ar"),
            ),
            
            const SizedBox(height: 15),
            
            _buildLanguageCard(
              title: "English",
              subtitle: "English",
              flag: "🇺🇸",
              isSelected: Get.locale?.languageCode == 'en',
              onTap: () => controller.changeLang("en"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageCard({
    required String title,
    required String subtitle,
    required String flag,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: iconColor, fontSize: 12),
                ),
              ],
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: primaryColor, size: 24)
            else
              const Icon(Icons.circle_outlined, color: Color(0xFFCBD5E1), size: 24),
          ],
        ),
      ),
    );
  }
}
