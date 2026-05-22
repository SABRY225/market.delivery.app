import 'package:get/get.dart';
import '../../core/class/status_request.dart';
import '../../core/functions/handling_data_controller.dart';
import '../../data/datasource/remote/order_data.dart';
import '../../core/class/crud.dart';
import '../../data/datasource/mock/MockOrderModel.dart';

class OrderController extends GetxController {
  OrderData orderData = OrderData(Crud());
  StatusRequest statusRequest = StatusRequest.none;
  List orders = [];

  getData() async {
    statusRequest = StatusRequest.loading;
    update();

    var response = await orderData.getData();
    statusRequest = handlingData(response);

    if (StatusRequest.success == statusRequest) {
      if (response['orders'] != null) {
        orders.clear();
        orders.addAll(response['orders']);
      } else {
        statusRequest = StatusRequest.failure;
      }
    } else {
      loadTemporaryData();
    }
    update();
  }

  @override
  void onInit() {
    getData();
    super.onInit();
  }

  void loadTemporaryData() {
    statusRequest = StatusRequest.success;
    orders = MockOrderModel.sampleOrders.map((mockOrder) {
      return {
        "id": mockOrder.id,
        "type": "delivery",
        "total": mockOrder.price,
        "status": "جديد",
        "createdAt": "2026-05-22",
        "city": {"name": "عمان"},
        "items": [
          {"name": mockOrder.storeName}
        ]
      };
    }).toList();
    update();
  }
}
