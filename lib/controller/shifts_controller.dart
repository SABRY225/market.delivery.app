import 'package:delivery/core/class/status_request.dart';
import 'package:delivery/core/functions/handling_data_controller.dart';
import 'package:delivery/core/services/local_storage.dart';
import 'package:delivery/data/datasource/remote/shifts_data.dart';
import 'package:get/get.dart';

class ShiftsController extends GetxController {
  ShiftsData shiftsData = ShiftsData(Get.find());
  List data = [];
  late StatusRequest statusRequest;

  Future<void> getData() async {
    statusRequest = StatusRequest.loading;
    update();
    String deliveryId = LocalStorage.getUserId().toString();
    dynamic response = await shiftsData.getShifts(deliveryId);
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

  @override
  void onInit() {
    getData();
    super.onInit();
  }
}
