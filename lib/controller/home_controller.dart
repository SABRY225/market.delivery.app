import 'dart:async';
import 'package:get/get.dart';
import '../core/class/status_request.dart';
import '../core/functions/handling_data_controller.dart';
import '../data/datasource/remote/home_data.dart';
import '../core/class/crud.dart';
import '../data/datasource/mock/MockOrderModel.dart';

class HomeController extends GetxController {
  HomeData homeData = HomeData(Crud());
  StatusRequest statusRequest = StatusRequest.none;
  bool isAvailable = false;
  List ordersList = [];

  toggleStatus(val) {
    isAvailable = val;
    update();
  }

  getData({bool showLoading = true}) async {
    if (showLoading) {
      statusRequest = StatusRequest.loading;
      update();
    }

    var response = await homeData.getData();
    statusRequest = handlingData(response);
    
    if (StatusRequest.success == statusRequest) {
      if (response['data'] != null && response['data'].isNotEmpty) {
        ordersList = response['data'];
      } else {
        loadTemporaryData();
      }
    } else {
      loadTemporaryData();
    }
    update();
  }

  acceptOrder(id) {
    ordersList.removeWhere((order) => order.id == id);
    update();
  }

  rejectOrder(id) {
    ordersList.removeWhere((order) => order.id == id);
    update();
  }

  @override
  void onInit() {
    getData();
    super.onInit();
  }

  void loadTemporaryData() {
    statusRequest = StatusRequest.success;
    ordersList = MockOrderModel.sampleOrders;
    update();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
