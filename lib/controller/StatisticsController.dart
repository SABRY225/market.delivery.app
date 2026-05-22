import 'package:delivery/data/datasource/remote/StatisticsData.dart';
import 'package:get/get.dart';
import '../../core/class/status_request.dart';
import '../../core/functions/handling_data_controller.dart';
import '../../core/class/crud.dart';

class StatisticsController extends GetxController {
  StatisticsData statisticsData = StatisticsData(Crud());
  StatusRequest statusRequest = StatusRequest.none;

  String totalCommission = "0";
  String orderCount = "0";
  List ordersLog = [];

  getStatisticsData() async {
    statusRequest = StatusRequest.loading;
    update();

    var response = await statisticsData.getStats();
    statusRequest = handlingData(response);

    if (StatusRequest.success == statusRequest) {
      if (response['data'] != null) {
        totalCommission = response['totalCommission']?.toString() ?? "0";
        orderCount = response['orderCount']?.toString() ?? "0";
        ordersLog = response['data'];
      } else {
        statusRequest = StatusRequest.failure;
      }
    } else {
      Get.snackbar("Error".tr, "Failed to retrieve updated data".tr);
    }
    update();
  }

  void loadTemporaryStatistics() {
    statusRequest = StatusRequest.success;
    totalCommission = "3326";
    orderCount = "2";
    ordersLog = [
      {
        "id": "ORD-9008",
        "customer": "Ahmed",
        "total": "1747.000",
        "commission": 1663,
        "date": "٤ مارس ٢٠٢٦",
        "time": "12:30 AM",
        "itemsCount": 0
      },
      {
        "id": "ORD-9007",
        "customer": "Ahmed",
        "total": "1768.000",
        "commission": 1663,
        "date": "٢١ فبراير ٢٠٢٦",
        "time": "10:42 PM",
        "itemsCount": 0
      }
    ];
    update();
  }

  @override
  void onInit() {
    getStatisticsData();
    super.onInit();
  }
}
