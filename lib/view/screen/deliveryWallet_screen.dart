import 'package:delivery/controller/delivery_wallet_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeliveryWalletScreen extends StatelessWidget {
  const DeliveryWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // استخدام Get.put مع الفحص لعدم دمج المكون مرتين
    final DeliveryWalletController controller =
        Get.isRegistered<DeliveryWalletController>()
            ? Get.find<DeliveryWalletController>()
            : Get.put(DeliveryWalletController());

    final isDark = Get.isDarkMode;
    final bgColor = Get.theme.scaffoldBackgroundColor;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF2D3142);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'delegate_wallet_and_orders'.tr,
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: cardColor,
        foregroundColor: textColor,
      ),
      body: GetBuilder<DeliveryWalletController>(
        builder: (controller) {
          if (controller.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.teal,
                strokeWidth: 3,
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => controller.fetchWalletData(),
            color: Colors.teal,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // شريط رسالة الخطأ إن وجد
                  if (controller.errorMessage != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF2F2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFD1D1)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.redAccent,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              controller.errorMessage!,
                              style: TextStyle(
                                color: Color(0xFFD32F2F),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // كروت الإحصائيات الماليات
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: 'amount_to_supply'.tr,
                          value:
                              "${controller.amountToHandOver.toStringAsFixed(2)} ${'currency'.tr}",
                          icon: Icons.account_balance_wallet_rounded,
                          primaryColor: Colors.amber.shade900,
                          backgroundColor: const Color(0xFFFFF8E1),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          title: 'total_orders_count'.tr,
                          value: "${controller.totalOrdersCount} ${'order'.tr}",
                          icon: Icons.local_shipping_rounded,
                          primaryColor: Colors.blueAccent,
                          backgroundColor: const Color(0xFFEBF3FF),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // عنوان قائمة الطلبات
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'orders_and_costs_log'.tr,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                      ),
                      Text(
                        "${controller.ordersLog.length} ${'record'.tr}",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // قائمة الطلبات
                  if (controller.ordersLog.isEmpty)
                    _buildEmptyState()
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.ordersLog.length,
                      itemBuilder: (context, index) {
                        final order = controller.ordersLog[index];
                        return _buildOrderCard(order);
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // كارت الإحصائيات
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color primaryColor,
    required Color backgroundColor,
  }) {
    final isDark = Get.isDarkMode;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final shadowColor = isDark ? Colors.transparent : Colors.black.withOpacity(0.03);
    final borderColor = isDark ? Colors.white12 : Colors.grey.withOpacity(0.08);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? primaryColor.withOpacity(0.1) : backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: primaryColor, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  // كارت تفاصيل الطلب
  Widget _buildOrderCard(dynamic order) {
    final isDark = Get.isDarkMode;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final shadowColor = isDark ? Colors.transparent : Colors.black.withOpacity(0.02);
    final borderColor = isDark ? Colors.white12 : Colors.grey.withOpacity(0.06);
    final textColor = isDark ? Colors.white : const Color(0xFF2D3142);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDark ? Colors.teal.withOpacity(0.1) : Colors.teal.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.restaurant_rounded,
              color: Colors.teal,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.restaurantName,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      "${'order'.tr} #${order.orderId}",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text(
                      order.time,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'order_cost'.tr,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "${order.totalPaidToRestaurant.toStringAsFixed(2)} ${'currency'.tr}",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.redAccent,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // حالة الشاشة عند خلو البيانات
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Column(
          children: [
            Icon(Icons.inbox_rounded, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              'no_orders_recorded_currently'.tr,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}