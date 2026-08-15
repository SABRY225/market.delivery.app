import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/locale_controller.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  static Color get primaryColor => const Color(0xFFFF5722);
  static Color get textColor => Get.isDarkMode ? Colors.white : const Color(0xFF1E293B);
  static Color get iconColor => Get.isDarkMode ? Colors.white70 : const Color(0xFF64748B);
  static Color get backgroundColor => Get.theme.scaffoldBackgroundColor;
  static Color get cardColor => Get.isDarkMode ? const Color(0xFF1E293B) : Colors.white;

  @override
  Widget build(BuildContext context) {
    LocaleController controller = Get.put(LocaleController());

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withOpacity(0.04),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: cardColor,
                      boxShadow: [
                        BoxShadow(
                          color: Get.isDarkMode ? Colors.transparent : primaryColor.withOpacity(0.1),
                          blurRadius: 30,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.language_rounded,
                      size: 70,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    "Select Language",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "اختر اللغة المناسبة للتطبيق",
                    style: TextStyle(color: iconColor, fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 50),
                  _buildModernButton(
                    title: "العربية",
                    subtitle: "اللغة العربية",
                    flag: "🇪🇬",
                    onPressed: () => controller.changeLang("ar"),
                  ),
                  const SizedBox(height: 20),
                  _buildModernButton(
                    title: "English",
                    subtitle: "English Language",
                    flag: "🇺🇸",
                    onPressed: () => controller.changeLang("en"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernButton({
    required String title,
    required String subtitle,
    required String flag,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Get.isDarkMode ? Colors.transparent : Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 50,
              width: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(flag, style: TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: iconColor, fontSize: 13),
                ),
              ],
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: primaryColor,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
