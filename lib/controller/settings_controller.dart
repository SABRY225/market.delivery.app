import 'package:delivery/core/services/local_storage.dart';
import 'package:delivery/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:permission_handler/permission_handler.dart';

class SettingsController extends GetxController {
  bool isNotificationsEnabled = true;
  bool isDarkModeEnabled = false;

  @override
  void onInit() {
    super.onInit();
    isDarkModeEnabled = LocalStorage.getDarkMode();
    _checkNotificationPermission();
  }

  Future<void> _checkNotificationPermission() async {
    PermissionStatus status = await Permission.notification.status;
    if (status.isGranted) {
      isNotificationsEnabled = LocalStorage.getNotifications();
    } else {
      isNotificationsEnabled = false;
      await LocalStorage.setNotifications(false);
    }
    update();
  }

  void toggleNotifications(bool value) async {
    if (value) {
      PermissionStatus status = await Permission.notification.request();
      if (status.isGranted) {
        isNotificationsEnabled = true;
        await LocalStorage.setNotifications(true);
      } else {
        isNotificationsEnabled = false;
        await LocalStorage.setNotifications(false);
        Get.defaultDialog(
          title: "permission_required".tr,
          middleText: "please_enable_notifications_in_settings".tr,
          textConfirm: "open_settings".tr,
          confirmTextColor: Colors.white,
          onConfirm: () {
            openAppSettings();
            Get.back();
          },
          textCancel: "cancel".tr,
        );
      }
    } else {
      isNotificationsEnabled = false;
      await LocalStorage.setNotifications(false);
    }
    update();
  }

  void toggleDarkMode(bool value) async {
    isDarkModeEnabled = value;
    await LocalStorage.setDarkMode(value);
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
    update();
    Future.delayed(const Duration(milliseconds: 300), () {
      Get.offAllNamed(AppRoutes.home);
    });
  }
}