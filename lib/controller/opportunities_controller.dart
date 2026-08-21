import 'package:delivery/core/class/status_request.dart';
import 'package:delivery/core/functions/handling_data_controller.dart';
import 'package:delivery/core/services/local_storage.dart';
import 'package:delivery/data/datasource/remote/opportunities_data.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class OpportunitiesController extends GetxController {
  OpportunitiesData opportunitiesData = OpportunitiesData(Get.find());
  List data = [];
  late StatusRequest statusRequest;

  Future<void> getData() async {
    data.clear();
    statusRequest = StatusRequest.loading;
    update();
    dynamic response = await opportunitiesData.getOpportunities();
    statusRequest = handlingData(response);
    if (StatusRequest.success == statusRequest) {
      if (response['status'] == "success") {
        data.addAll(response['data']);
      } else {
        statusRequest = StatusRequest.failure;
      }
    }
    update();
  }

  Future<void> acceptOpportunity(String id) async {
    statusRequest = StatusRequest.loading;
    update();
    String deliveryId = LocalStorage.getUserId().toString();
    dynamic response = await opportunitiesData.acceptOpportunity(id, deliveryId);
    statusRequest = handlingData(response);
    if (StatusRequest.success == statusRequest) {
      if (response['status'] == "success") {
        Get.snackbar("Success", "Opportunity accepted successfully",
            backgroundColor: Colors.green, colorText: Colors.white);
        getData(); 
      } else {
        Get.snackbar("Error", response['message'] ?? "Error accepting opportunity",
            backgroundColor: Colors.red, colorText: Colors.white);
        statusRequest = StatusRequest.failure;
      }
    } else {
      Get.snackbar("Error", "Network error",
            backgroundColor: Colors.red, colorText: Colors.white);
    }
    update();
  }

  @override
  void onInit() {
    getData();
    super.onInit();
  }
}