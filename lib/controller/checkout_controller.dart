import '../../../controller/order/order_controller.dart';
import '../../../core/services/local_storage.dart';
import '../../../data/datasource/remote/linkapi.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'cart_controller.dart';

class CheckoutController extends GetxController {
  var cities = [].obs;
  var selectedCity = {}.obs;
  var isLoading = true.obs;
  var isSubmitting = false.obs;

  final phoneController = TextEditingController();
  final phone2Controller = TextEditingController();
  final addressDetailsController = TextEditingController();
  var selectedPaymentMethod = "cash".obs;
  @override
  void onInit() {
    fetchCities();
    super.onInit();
  }

  void fetchCities() async {
    try {
      isLoading(true);
      var response = await http.get(Uri.parse(AppLink.hippingCities));
      if (response.statusCode == 200) {
        cities.value = jsonDecode(response.body);
      }
    } catch (e) {
      Get.snackbar("Error".tr, "Could not load cities".tr);
    } finally {
      isLoading(false);
    }
  }

  double get shippingCost => selectedCity.isEmpty
      ? 0.0
      : double.parse(selectedCity['price'].toString());

  // إرسال الطلب للسيرفر
  Future<void> placeOrder(CartController cartController) async {
    try {
      isSubmitting(true);
      final name = LocalStorage.getName() ?? "User";
      final userId = LocalStorage.getUserId();
      Map<String, dynamic> orderData = {
        "fullName": name,
        "userId": userId,
        "phone": "+962${phoneController.text}",
        "alternatePhone": phone2Controller.text.isNotEmpty
            ? "+962${phone2Controller.text}"
            : null,
        "city": selectedCity['id'],
        "address": addressDetailsController.text,
        "shipping": shippingCost,
        "subtotal": cartController.total,
        "total": cartController.total + shippingCost,
        "paymentMethod": selectedPaymentMethod.value,
        "cartItems": cartController.cartItems
            .map(
              (p) => {
                "id": p['id'],
                "image": p['image'],
                "name": p['name'],
                "quantity": p['quantity'],
                "price": p['price'],
              },
            )
            .toList(),
      };

      var response = await http.post(
        Uri.parse(AppLink.createOrder),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(orderData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        cartController.clearCart();
        Get.offAllNamed('/home');
        if (Get.isRegistered<OrderController>()) {
          Get.find<OrderController>().getData();
        }
        Get.snackbar(
          "Success".tr,
          "Order placed successfully!".tr,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        try {
          var responseData = jsonDecode(response.body);

          String errorMessage =
              responseData["error"] ?? 'Failed to place order'.tr;

          Get.snackbar(
            "Error".tr,
            errorMessage,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        } catch (e) {
          Get.snackbar(
            "Error".tr,
            "Something went wrong".tr,
            backgroundColor: Colors.red,
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        "Error".tr,
        "Something went wrong, please try again".tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSubmitting(false);
    }
  }
}
