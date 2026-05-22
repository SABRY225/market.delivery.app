import 'package:delivery/controller/StatisticsController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/class/status_request.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  static const Color primaryColor = Color(0xFFFF5722);
  static const Color textColor = Color(0xFF1E293B);
  static const Color iconColor = Color(0xFF64748B);
  static const Color backgroundColor = Color.fromARGB(255, 238, 236, 236);

  @override
  Widget build(BuildContext context) {
    Get.put(StatisticsController());

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          "statistics".tr,
          style: const TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: textColor),
          onPressed: () => Get.back(),
        ),
      ),
      body: GetBuilder<StatisticsController>(
        builder: (controller) {
          if (controller.statusRequest == StatusRequest.loading) {
            return const Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          } else if (controller.statusRequest == StatusRequest.offlinefailure) {
            return Center(
              child: Text(
                "no_internet_connection".tr,
                style: const TextStyle(color: textColor),
              ),
            );
          } else if (controller.statusRequest == StatusRequest.serverfailure) {
            return Center(
              child: Text(
                "server_error".tr,
                style: const TextStyle(color: textColor),
              ),
            );
          } else {
            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20.0),
              children: [
                _buildEarningsOverviewCard(controller),
                const SizedBox(height: 25),
                Text(
                  "Record your latest orders".tr,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.ordersLog.length,
                  itemBuilder: (context, index) {
                    final order = controller.ordersLog[index];
                    return _buildOrderHistoryCard(order);
                  },
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildEarningsOverviewCard(StatisticsController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: textColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: textColor.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Your current total commission".tr,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                controller.totalCommission,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                "egp".tr,
                style: const TextStyle(
                  color: primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Divider(color: Colors.white10, thickness: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Number of completed orders".tr,
                    style: TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${controller.orderCount} "+"orders".tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.bar_chart_rounded,
                color: primaryColor.withOpacity(0.8),
                size: 28,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderHistoryCard(Map<String, dynamic> order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "order number:".tr+" ${order['id']}",
                style: const TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                "${order['commission']} + "+"commission".tr,
                style: const TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: Color(0xFFF1F5F9), thickness: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.person_outline, color: iconColor, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    "The client:".tr+" ${order['customer']}",
                    style: const TextStyle(color: iconColor, fontSize: 13),
                  ),
                ],
              ),
              Text(
                "total:".tr+" ${double.parse(order['total'] ?? '0').toStringAsFixed(2)} egp",
                style: const TextStyle(
                  color: textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    color: iconColor,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "${order['date']}",
                    style: const TextStyle(color: iconColor, fontSize: 12),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.access_time, color: iconColor, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    "${order['time']}",
                    style: const TextStyle(color: iconColor, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
