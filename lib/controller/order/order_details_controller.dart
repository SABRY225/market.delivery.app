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
        Get.snackbar(
          "success_title".tr, 
          "order_cancelled_success".tr,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        orderController.getData();
        Get.toNamed(AppRoutes.orders);
        return true;
      } else {
        Get.snackbar(
          "error_title".tr,
          response.body['message'] ?? "order_cancelled_failed".tr,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        "error_title".tr, 
        "server_error".tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
          "success_title".tr,
          "order_delivered_success".tr,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        orderController.getData();
        Get.toNamed(AppRoutes.orders);
        return true;
      } else {
        Get.snackbar(
          "error_title".tr,
          response.body['message'] ?? "order_delivered_failed".tr,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        "error_title".tr, 
        "server_error".tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}