import 'package:delivery/controller/order/order_controller.dart';
import 'package:delivery/data/datasource/remote/linkapi.dart';
import 'package:delivery/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderDetailsController extends GetxController {
  var isLoading = false.obs;
  OrderController orderController = Get.put(OrderController());
  Future<bool> cancelOrder(String orderId, String reason) async {
    try {
      isLoading.value = true;

      final response = await GetConnect().patch(
        "${AppLink.changeOrderStatus}/$orderId/status-order",
        {"status": "cancelled", "dasc": reason},
      );

      if (response.statusCode == 200) {
        Get.snackbar("تم بنجاح", "تم إلغاء الطلب بنجاح",backgroundColor: Colors.green);
        orderController.getData();
        Get.toNamed(AppRoutes.orders);
        return true;
      } else {
        Get.snackbar(
          "خطأ",
          response.body['message'] ?? "فشلت عملية إلغاء الطلب",
          backgroundColor: Colors.red
        );
        return false;
      }
    } catch (e) {
      Get.snackbar("خطأ", "حدث خطأ في الاتصال بالسيرفر");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // دالة تسليم الطلب
  Future<bool> deliverOrder(String orderId) async {
    try {
      isLoading.value = true;

      final response = await GetConnect().patch(
        "${AppLink.changeOrderStatus}/$orderId/status-order",
        {"status": "success"},
      );
      if (response.statusCode == 200) {
        Get.snackbar(
          "تم بنجاح",
          "تم تسجيل تسليم الطلب بنجاح",
          backgroundColor: Colors.green,
        );
        orderController.getData();
        Get.toNamed(AppRoutes.orders);
        return true;
      } else {
        Get.snackbar(
          "خطأ",
          response.body['message'] ?? "فشلت عملية تسليم الطلب",
          backgroundColor: Colors.red,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar("خطأ", "حدث خطأ في الاتصال بالسيرفر");
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
