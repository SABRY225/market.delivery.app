import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/local_storage.dart';
import '../../routes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static Color get primaryColor => const Color(0xFFFF5722); 
  static Color get textColor => Get.isDarkMode ? Colors.white : const Color(0xFF1E293B);    
  static Color get iconColor => Get.isDarkMode ? Colors.white70 : const Color(0xFF64748B);    
  static Color get backgroundColor => Get.theme.scaffoldBackgroundColor;
  static Color get cardColor => Get.isDarkMode ? const Color(0xFF1E293B) : Colors.white;

  @override
  Widget build(BuildContext context) {
    final name = LocalStorage.getName() ?? "user".tr;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textColor),
          onPressed: () => Get.offAllNamed(AppRoutes.home),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                backgroundImage: AssetImage("assets/images/user.png"),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              name,
              style: TextStyle(
                color: textColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildListTile(
                      icon: Icons.inventory_2_outlined,
                      title: "my_orders".tr,
                      onTap: () => Get.toNamed(AppRoutes.orders),
                    ),
                    _buildListTile(
                      icon: Icons.info_outline,
                      title: "info_delivery".tr,
                      onTap: () => Get.toNamed(AppRoutes.infoDelivery),
                    ),
                    _buildListTile(
                      icon: Icons.bar_chart_outlined,
                      title: "statistics".tr,
                      onTap: () => Get.toNamed(AppRoutes.statistics),
                    ),
                    _buildListTile(
                      icon: Icons.contact_mail, 
                      title: "contact".tr,
                      onTap: () => Get.toNamed(AppRoutes.contact),
                    ),
                    _buildListTile(
                      icon: Icons.language, 
                      title: "app_language".tr,
                      onTap: () => Get.toNamed(AppRoutes.selectLanguage),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      child: Divider(color: Color(0xFFCBD5E1), thickness: 1),
                    ),
                    _buildListTile(
                      icon: Icons.logout,
                      title: "logout".tr,
                      // تم تصحيح الاسم هنا ليطابق المتغير الموجود في الدالة بالأسفل
                      customIconColor: const Color.fromARGB(255, 241, 234, 234),
                      onTap: () async {
                        LocalStorage.clear();
                        Get.offAllNamed(AppRoutes.login);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? customIconColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (customIconColor ?? iconColor).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: customIconColor ?? iconColor, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Color(0xFFCBD5E1),
          size: 14,
        ),
        onTap: onTap, // تم إبقاء استدعاء واحد فقط هنا
      ),
    );
  }
}