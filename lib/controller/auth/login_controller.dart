import 'package:delivery/core/services/local_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; 
import '../../../routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/class/status_request.dart';
import '../../../core/functions/handling_data_controller.dart';
import '../../../data/datasource/remote/auth/login_data.dart';
import '../../../core/class/crud.dart';

class LoginController extends GetxController {
  late TextEditingController phone;
  late TextEditingController password;
  bool isPasswordHidden = true;
  LoginData loginData = LoginData(Crud());

  StatusRequest statusRequest = StatusRequest.none;

  @override
  void onInit() {
    phone = TextEditingController();
    password = TextEditingController();
    super.onInit();
  }
Future<void> login() async {
  if (phone.text.isEmpty) {
    Get.snackbar("alert".tr, "Please enter your phone number.".tr);
    return;
  }
  if (password.text.isEmpty) {
    Get.snackbar("alert".tr, "Please enter your password.".tr);
    return;
  }
  statusRequest = StatusRequest.loading;
  update();
  String? fcmToken;
  try {
    fcmToken = await FirebaseMessaging.instance.getToken();
    print("FCM Token Retrieved: $fcmToken");
  } catch (e) {
    print("Error getting FCM Token: $e");
  }
  dynamic response = await loginData.postData(phone.text, password.text, fcmToken);
  statusRequest = handlingData(response);

  if (StatusRequest.success == statusRequest) {
    print("Login successful: $response");
    int pUserId = 0;
    if (response['user']['id'] != null) {
      pUserId = int.tryParse(response['user']['id'].toString()) ?? 0;
    }
    bool pOnline = false;
    if (response['user']['online'] != null) {
      if (response['user']['online'] is bool) {
        pOnline = response['user']['online'];
      } else {
        pOnline = response['user']['online'].toString().toLowerCase() == 'true' || response['user']['online'].toString() == '1';
      }
    }

    String pToken = response['token']?.toString() ?? '';
    print("vehicleType: ${response['user']?['vehicleType']?.toString()}");
    LocalStorage.setUser(
      token: pToken,
      email: response['user']['email']?.toString() ?? '',
      name: response['user']['name']?.toString() ?? '',
      workingMode: response['user']['workingMode']?.toString() ?? '',
      vehicleType: response['user']['vehicleType']?.toString() ?? '',
      userId: pUserId,
      online: pOnline,
    );

    print("🔑 [LOCAL STORAGE] Token saved: ${LocalStorage.getToken()}");

    Get.offNamed(AppRoutes.idscan);

  } else {
    Get.defaultDialog(
      title: "Login failed".tr,
      middleText: "Email address not registered with us".tr,
      middleTextStyle: const TextStyle(color: Colors.white),
      backgroundColor: const Color(0xFF1A1A1A),
    );
    statusRequest = StatusRequest.failure;
  }

  update();
}
  @override
  void onClose() {
    phone.dispose();
    password.dispose();
    super.onClose();
  }
}