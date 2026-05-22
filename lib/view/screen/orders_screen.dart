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
    Get.put(OrderController());

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
                return _buildOrderCard(controller.orders[index]);
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildOrderCard(Map? order) {
    if (order == null) return const SizedBox();

    String type = order['type'] ?? "عام";
    String total = order['total']?.toString() ?? "0";
    String status = order['status'] ?? "غير محدد";
    String createdAt = order['createdAt']?.toString().split('T')[0] ?? "";
    Color bgColor = const Color(0xFF94A3B8);

    if (order['status'] == 'جدide' || order['status'] == 'جديد') {
      status = "new";
      bgColor = const Color(0xFF10B981);
    } else if (order['status'] == 'قيد التنفيذ') {
      status = "in_processing";
      bgColor = const Color(0xFFF59E0B);
    } else if (order['status'] == 'جاري الشحن') {
      status = "in_Shopping";
      bgColor = const Color(0xFF3B82F6);
    } else if (order['status'] == 'مكتمل') {
      status = "completed";
      bgColor = const Color(0xFF64748B);
    } else if (order['status'] == 'ملغي') {
      status = "cancelled";
      bgColor = const Color(0xFFEF4444);
    } else if (order['status'] == 'مرتجع') {
      status = "returned";
      bgColor = const Color(0xFF78350F);
    }

    String city = "غير محدد";
    if (order['city'] != null && order['city'] is Map) {
      city = order['city']['name'] ?? "مدينة غير معروفة";
    }

    String itemName = "طلب فارغ";
    if (order['items'] != null && (order['items'] as List).isNotEmpty) {
      itemName = order['items'][0]['name'] ?? "منتج بدون اسم";
    }

    bool isSilver = order['type'] == "silver";

    return Container(
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
        border: Border.all(
          color: isSilver
              ? Colors.blueGrey.withOpacity(0.2)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: isSilver
                      ? Colors.blueGrey.withOpacity(0.1)
                      : primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  (type.tr).toUpperCase(),
                  style: TextStyle(
                    color: isSilver ? Colors.blueGrey[700] : primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                '$total ${"egp".tr}',
                style: const TextStyle(
                  color: textColor,
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
            Icons.shopping_bag_outlined,
            itemName,
            textColor,
            isBold: true,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.calendar_today_outlined,
            "${"Order Date:".tr} $createdAt",
            iconColor,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildInfoRow(
                  Icons.location_on_outlined,
                  city,
                  iconColor,
                ),
              ),
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
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: displayColor,
              fontSize: 14,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
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
            style: const TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
