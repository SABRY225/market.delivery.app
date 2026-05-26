import 'package:delivery/routes.dart';
import 'package:get/get.dart';
import '../../core/class/status_request.dart';
import '../../core/functions/handling_data_controller.dart';
import '../../data/datasource/remote/order_data.dart';
import '../../core/class/crud.dart';
import '../../data/datasource/mock/MockOrderModel.dart';

class OrderController extends GetxController {
  final OrderData orderData = OrderData(Crud());
  StatusRequest statusRequest = StatusRequest.none;
  List orders = [];
  int orderCounts = 0;

  Future<void> getData() async {
    statusRequest = StatusRequest.loading;
    update();

    var response = await orderData.getData();
    statusRequest = handlingData(response);

    if (StatusRequest.success == statusRequest) {
      if (response['orders'] != null) {
        orders.clear();
        orders.addAll(response['orders']);
        
        _calculateActiveOrders();
      } else {
        statusRequest = StatusRequest.failure;
      }
    } else {
      Get.snackbar("Error".tr, "Failed to retrieve updated data".tr);
    }
    
    update();
  }

  void _calculateActiveOrders() {
    orderCounts = 0;
    for (var order in orders) {
      if (order["status"] != "delivered" && order["status"] != "cancelled") {
        orderCounts += 1;
      }
    }
  }

  void goToOrderDetails(order){
     Get.toNamed(AppRoutes.detailesOrder, arguments: {
      "orderData": order,
    });
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
          {"name": mockOrder.storeName},
        ],
      };
    }).toList();
    
    _calculateActiveOrders(); 
    update();
  }
}