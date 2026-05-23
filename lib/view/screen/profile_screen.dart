import '../../../controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/local_storage.dart';
import '../../routes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const Color primaryColor = Color(0xFFFF5722); 
  static const Color textColor = Color(0xFF1E293B);    
  static const Color iconColor = Color(0xFF64748B);    
  static const Color backgroundColor = Color.fromARGB(255, 238, 236, 236);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());
    Future.microtask(() => controller.fetchProfileData());
    final name = LocalStorage.getName() ?? "user".tr;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: textColor),
          onPressed: () => Get.offAllNamed(AppRoutes.home),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: textColor, size: 20),
            onPressed: () => controller.fetchProfileData(),
          ),
        ],
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
              style: const TextStyle(
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
                      iconColor: Colors.redAccent,
                      onTap: () async {
                        await LocalStorage.clear();
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
    Color iconColor = iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
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
        onTap: onTap,
      ),
    );
  }
}
