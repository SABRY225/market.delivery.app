import '../../../routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/class/status_request.dart';
import '../../../core/functions/handling_data_controller.dart';
import '../../../data/datasource/remote/auth/signup_data.dart';
import '../../../core/class/crud.dart';

class SignUpController extends GetxController {
  late TextEditingController name;
  late TextEditingController email;
  late TextEditingController phone;
  late TextEditingController address;

  SignUpData signupData = SignUpData(Crud());

  StatusRequest statusRequest = StatusRequest.none;

  @override
  void onInit() {
    name = TextEditingController();
    email = TextEditingController();
    phone = TextEditingController();
    address = TextEditingController();
    super.onInit();
  }

  signUp() async {
    if (email.text.isEmpty) {
      return Get.snackbar("alert".tr, "Please enter your email address.".tr);
    }
    if (phone.text.isEmpty) {
      return Get.snackbar("alert".tr, "Please enter your phone number.".tr);
    }
    if (address.text.isEmpty) {
      return Get.snackbar("alert".tr, "Please enter the address.".tr);
    }

    statusRequest = StatusRequest.loading;
    update();
    var response = await signupData.postData(
      name.text,
      email.text,
      phone.text,
      address.text,
    );
    statusRequest = handlingData(response);

    if (StatusRequest.success == statusRequest) {
      Get.offNamed(AppRoutes.otp, arguments: {"email": email.text});
    } else {
      Get.defaultDialog(
        title: "Login failed".tr,
        middleText: "The email address is already registered with us.".tr,
        middleTextStyle: const TextStyle(color: Colors.white),
        backgroundColor: const Color(0xFF1A1A1A),
      );
      statusRequest = StatusRequest.failure;
    }

    update();
  }

  @override
  void onClose() {
    name.dispose();
    email.dispose();
    phone.dispose();
    address.dispose();
    super.onClose();
  }
}
