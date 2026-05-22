import 'package:delivery/core/services/local_storage.dart';

import '../../../routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/class/status_request.dart';
import '../../../core/functions/handling_data_controller.dart';
import '../../../data/datasource/remote/auth/login_data.dart';
import '../../../core/class/crud.dart';

class LoginController extends GetxController {
  late TextEditingController email;

  LoginData loginData = LoginData(Crud());

  StatusRequest statusRequest = StatusRequest.none;

  @override
  void onInit() {
    email = TextEditingController();
    super.onInit();
  }

  login() async {
    if (email.text.isEmpty) {
      return Get.snackbar("alert".tr, "Please enter your email address.".tr);
    }

    statusRequest = StatusRequest.loading;
    update();
    var response = await loginData.postData(email.text);
    statusRequest = handlingData(response);

    if (StatusRequest.success == statusRequest) {
        await LocalStorage.setUser(
        token: response['token'] ?? '',
        email:  response['user']['email'] ?? '',
        name: response['user']['name'] ?? '',
        userId: response['user']['id'] ?? '',
      );
      Get.offNamed(AppRoutes.home);
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
    email.dispose();
    super.onClose();
  }
}
