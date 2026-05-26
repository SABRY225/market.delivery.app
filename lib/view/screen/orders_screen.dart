import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/order/order_controller.dart';
import '../../../core/class/status_request.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  static const Color primaryColor = Color(0xFFFF5722);
  static const Color textColor = Color(0xFF1E293B);
  static const Color iconColor = Color(0xFF64748B);
  static const Color backgroundColor = Color.fromARGB(255, 238, 236, 236);

  @override
  Widget build(BuildContext context) {
    // نتحقق مما إذا كان الكنترولر مسجلاً بالفعل، وإذا لم يكن، نقوم بإنشائه
    final OrderController controller = Get.put(OrderController());

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          "my_orders".tr,
          style: const TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: textColor),
      ),
      body: GetBuilder<OrderController>(
        builder: (controller) {
          if (controller.statusRequest == StatusRequest.loading) {
            return const Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          } else if (controller.statusRequest == StatusRequest.offlinefailure) {
            return _buildErrorState(
              "no_internet_connection".tr,
              Icons.wifi_off_rounded,
            );
          } else if (controller.statusRequest == StatusRequest.serverfailure) {
            return _buildErrorState("server_error".tr, Icons.dns_rounded);
          } else {
            if (controller.orders.isEmpty) {
              return _buildErrorState(
                "No orders currently available".tr,
                Icons.inventory_2_outlined,
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              physics: const BouncingScrollPhysics(),
              itemCount: controller.orders.length,
              itemBuilder: (context, index) {
                if (controller.orders[index] == null) return const SizedBox();
                return _buildOrderCard(controller.orders[index], controller);
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildOrderCard(Map? order, OrderController controller) {
    if (order == null) return const SizedBox();

    String orderId = order['id']?.toString() ?? "";
    String customerName = order['customer'] ?? "عميل غير معروف";
    String total = order['total']?.toString() ?? "0";
    String status = order['status'] ?? "غير محدد";
    String startTime = order['startTime'] ?? "";
    String paymentMethod = order['payment'] ?? "كاش";
    Color bgColor = const Color(0xFF94A3B8);

    // تحديد الحالات والألوان
    if (order['status'] == 'pending') {
      status = "new";
      bgColor = const Color.fromARGB(137, 16, 185, 69);
    } else if (order['status'] == 'confirmed') {
      status = "in_confirmed";
      bgColor = const Color(0xFF10B981);
    } else if (order['status'] == 'processing') {
      status = "in_processing";
      bgColor = const Color(0xFFF59E0B);
    } else if (order['status'] == 'searching') {
      status = "in_searching";
      bgColor = const Color(0xFFF59E0B);
    } else if (order['status'] == 'shipped') {
      status = "in_Shopping";
      bgColor = const Color(0xFF3B82F6);
    } else if (order['status'] == 'delivered') {
      status = "completed";
      bgColor = const Color(0xFF64748B);
    } else if (order['status'] == 'cancelled') {
      status = "cancelled";
      bgColor = const Color(0xFFEF4444);
    }

    String firstItemName = "Order without products".tr;
    if (order['items'] != null && (order['items'] as List).isNotEmpty) {
      firstItemName = order['items'][0]['name'] ?? "Product without a name".tr;
      if ((order['items'] as List).length > 1) {
        firstItemName += " (+${(order['items'] as List).length - 1})";
      }
    }

    // تغليف الكارت بـ InkWell لجعل الكارت بأكمله قابلاً للضغط
    return InkWell(
      onTap: () {
        if (order['status'] != 'cancelled' && order['status'] != 'delivered' ) {
          controller.goToOrderDetails(order); 
        } else {
          Get.snackbar(
            "تنبيه".tr, 
            "لا يمكن تعديل أو فتح الطلبات المكتملة".tr,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor:Color(0xFFFF5722)
          );
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "order number:".tr + " #$orderId",
                  style: const TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '$total ${"egp".tr}',
                  style: const TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: Color(0xFFE2E8F0), thickness: 1),
            ),
            _buildInfoRow(
              Icons.person_outline,
              "${"The client:".tr} $customerName",
              textColor,
              isBold: true,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.shopping_bag_outlined,
              firstItemName,
              textColor,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoRow(
                  Icons.access_time,
                  startTime,
                  iconColor,
                ),
                _buildInfoRow(
                  Icons.payment_outlined,
                  paymentMethod.toUpperCase().tr,
                  iconColor,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String text,
    Color displayColor, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: isBold ? primaryColor : iconColor, size: 18),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: displayColor,
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }

  Widget _buildErrorState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor.withOpacity(0.4), size: 60),
          const SizedBox(height: 15),
          Text(
            message,
            style: const TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
