import 'package:delivery/controller/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static Color get primaryColor => const Color(0xFF002AFF);
  static Color get textColor => Get.isDarkMode ? Colors.white : const Color(0xFF1E293B);

  static Color get backgroundColor => Get.theme.scaffoldBackgroundColor;
  static Color get cardColor => Get.isDarkMode ? const Color(0xFF1E293B) : Colors.white;

  @override
  Widget build(BuildContext context) {
    Get.put(SettingsController());

    return GetBuilder<SettingsController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            title: Text(
              "settings".tr,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: textColor),
              onPressed: () => Get.back(),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "settings_description".tr,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Get.isDarkMode ? Colors.transparent : Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        value: controller.isNotificationsEnabled,
                        onChanged: (val) => controller.toggleNotifications(val),
                        activeThumbColor: primaryColor,
                        title: Text(
                          "notifications".tr,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        secondary: Icon(Icons.notifications_active_rounded, color: primaryColor),
                      ),
                      Divider(height: 1, indent: 16, endIndent: 16),
                      SwitchListTile(
                        value: controller.isDarkModeEnabled,
                        onChanged: (val) => controller.toggleDarkMode(val),
                        activeThumbColor: primaryColor,
                        title: Text(
                          "appearance".tr,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        subtitle: Text(
                          controller.isDarkModeEnabled ? "dark_mode".tr : "light_mode".tr,
                          style: TextStyle(fontSize: 12),
                        ),
                        secondary: Icon(
                          controller.isDarkModeEnabled ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}