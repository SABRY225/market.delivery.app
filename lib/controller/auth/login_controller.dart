import 'package:delivery/core/services/local_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // تأكد من الاستيراد
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
  
  // 1. جلب توكن الفايربيز الحقيقي الخاص بالجهاز هنا
  String? fcmToken;
  try {
    fcmToken = await FirebaseMessaging.instance.getToken();
    print("FCM Token Retrieved: $fcmToken");
  } catch (e) {
    print("Error getting FCM Token: $e");
    // يمكنك إما إيقاف العملية أو السماح بالدخول بدون إشعارات حسب رغبتك
  }
  
  // 2. تمرير الـ fcmToken إلى دالة البوست (تأكد من تعديل ملف LoginData كما في الخطوة القادمة)
  dynamic response = await loginData.postData(phone.text, password.text, fcmToken);
  statusRequest = handlingData(response);

  if (StatusRequest.success == statusRequest) {
    print("Login successful: $response");
    // حفظ بيانات المستخدم محلياً
    LocalStorage.setUser(
      token: response['token'] ?? '',
      email: response['user']['email'] ?? '',
      name: response['user']['name'] ?? '',
      workingMode: response['user']['workingMode'] ?? '',
      userId: response['user']['id'] ?? '',
      online: response['user']['online'] ?? '',
    );

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
