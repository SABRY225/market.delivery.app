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
        
        // حساب العداد بشكل صحيح وآمن بعد نجاح جلب البيانات
        _calculateActiveOrders();
      } else {
        statusRequest = StatusRequest.failure;
      }
    } else {
      Get.snackbar("Error".tr, "Failed to retrieve updated data".tr);
    }
    
    update();
  }

  // دالة خاصة لحساب الطلبات النشطة لمنع تكرار اللوجيك
  void _calculateActiveOrders() {
    orderCounts = 0; // تصفير العداد أولاً لمنع التراكم العشوائي
    for (var order in orders) {
      if (order["status"] != "delivered" && order["status"] != "rejected") {
        orderCounts += 1;
      }
    }
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
    
    // تحديث العداد حتى للبيانات التجريبية لكي يظهر في الـ Navigation Bar فوراً
    _calculateActiveOrders(); 
    update();
  }
}