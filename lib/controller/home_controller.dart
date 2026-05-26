import 'dart:async';
import 'package:delivery/controller/order/order_controller.dart';
import 'package:delivery/core/services/local_storage.dart';
import 'package:get/get.dart';
import '../core/class/status_request.dart';
import '../core/functions/handling_data_controller.dart';
import '../data/datasource/remote/home_data.dart';
import '../core/class/crud.dart';
import '../core/services/notification_service.dart';

class HomeController extends GetxController {
  HomeData homeData = HomeData(Crud());
  OrderController orderController = Get.put(OrderController());
  StatusRequest statusRequest = StatusRequest.none;
  bool isAvailable = LocalStorage.getOnline() ?? false;
  var ordersList = [];
  Timer? _timer;

  int orderReadyCont = 0;

  static const String _notifiedOrdersKey = "notified_orders_ids";

  toggleStatus(val) async {
    var response = await homeData.postStatus(val);
    statusRequest = handlingData(response);

    if (StatusRequest.success == statusRequest) {
      isAvailable = val;
    } else {
      Get.snackbar("Error".tr, "Failed updated status".tr);
    }
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
      if (response['data'] != null) {
        List rawList = response['data'];

        List<String> savedOrderIds = _getSavedOrderIds();

        bool hasNewOrder = false;
        List<String> currentOrderIds = [];

        for (var order in rawList) {
          String id = order['orders_id']?.toString() ?? "";
          if (id.isNotEmpty) {
            currentOrderIds.add(id);
            
            if (!savedOrderIds.contains(id)) {
              hasNewOrder = true;
            }
          }
        }

        if (hasNewOrder && savedOrderIds.isNotEmpty) {
          NotificationService.showNotification(
            title: "طلب جديد! 🚨",
            body: "لديك طلب جديد في إنتظار القبول.",
          );
        }

        _saveOrderIds(currentOrderIds);

        ordersList = rawList;
        orderReadyCont = ordersList.length;
      } else {
        Get.snackbar("Error".tr, "Failed to retrieve updated data".tr);
      }
    } else {
      Get.snackbar("Error".tr, "Failed to retrieve updated data".tr);
    }
    update();
  }

  
  List<String> _getSavedOrderIds() {
    var savedData = LocalStorage.get(_notifiedOrdersKey); 
    if (savedData != null) {
      return List<String>.from(savedData);
    }
    return [];
  }

  void _saveOrderIds(List<String> ids) {
    LocalStorage.save(_notifiedOrdersKey, ids);
  }


  acceptOrder(id) async {
    var response = await homeData.postAccept(id);
    statusRequest = handlingData(response);

    if (StatusRequest.success == statusRequest) {
      if (response['data'] != null) {
        getData();
        orderController.getData();
        update();
      } else {
        Get.snackbar("Error".tr, "Failed to accepted order".tr);
      }
    } else {
      Get.snackbar("Error".tr, "Failed to accepted order".tr);
    }
  }

  rejectOrder(id) async {
    var response = await homeData.postReject(id);
    statusRequest = handlingData(response);

    if (StatusRequest.success == statusRequest) {
      if (response['data'] != null) {
        getData();
        orderController.getData();
        update();
      } else {
        Get.snackbar("Error".tr, "Failed to accepted order".tr);
      }
    } else {
      Get.snackbar("Error".tr, "Failed to accepted order".tr);
    }
  }

  @override
  void onInit() {
    getData();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      getData(showLoading: false);
    });
    super.onInit();
  }

  void loadTemporaryData() {
    statusRequest = StatusRequest.success;
    ordersList = [];
    update();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}