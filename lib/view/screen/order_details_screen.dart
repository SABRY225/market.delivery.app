import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key});

  // Reusing your application design tokens
  static const Color primaryColor = Color(0xFFFF5722);
  static const Color textColor = Color(0xFF1E293B);
  static const Color iconColor = Color(0xFF64748B);
  static const Color backgroundColor = Color.fromARGB(255, 238, 236, 236);

  @override
  Widget build(BuildContext context) {
    // Safely extract arguments passed from OrderController
    final Map orderData = Get.arguments?['orderData'] ?? {};
    print("orderData---:$orderData");
    String orderId = orderData['id']?.toString() ?? "";
    String customerName = orderData['customer'] ?? "عميل غير معروف";
    String total = orderData['total']?.toString() ?? "0";
    String status = orderData['status'] ?? "غير محدد";
    String startTime = orderData['startTime'] ?? "";
    String paymentMethod = orderData['payment'] ?? "كاش";
    List items = orderData['items'] as List? ?? [];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          "${"order_details".tr} #$orderId",
          style: const TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: textColor),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Order Status Summary Banner
            _buildStatusBanner(status),
            const SizedBox(height: 16),

            // 2. Customer & Delivery Info Section
            _buildSectionCard(
              title: "customer_info".tr,
              icon: Icons.person_outline,
              child: Column(
                children: [
                  _buildDetailRow("The client:".tr, customerName),
                  const Divider(height: 20),
                  _buildDetailRow("time".tr+":", startTime),
                  const Divider(height: 20),
                  _buildDetailRow("payment".tr+":", paymentMethod.toUpperCase().tr),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. Products/Items Breakdown List
            _buildSectionCard(
              title: "order_items".tr,
              icon: Icons.shopping_basket_outlined,
              child: items.isEmpty
                  ? Center(child: Text("Order without products".tr))
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const Divider(height: 20),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        String name =
                            item['name'] ?? "Product without a name".tr;
                        String qty = item['qty']?.toString() ?? "1";
                        String price = item['price']?.toString() ?? "0";
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                "$name  x$qty",
                                style: const TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Text(
                              "$price ${"egp".tr}",
                              style: const TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),

            // 4. Receipt Total Calculation Summary
            _buildSectionCard(
              title: "receipt_summary".tr,
              icon: Icons.receipt_long_outlined,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "total_amount".tr,
                        style: const TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "$total ${"egp".tr}",
                        style: const TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 5. Context-Aware Action Button
            _buildActionButton(status, orderData),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
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
            children: [
              Icon(icon, color: primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: Color(0xFFE2E8F0), thickness: 1),
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: iconColor, fontSize: 14)),
        Text(
          value,
          style: const TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBanner(String status) {
    Color bannerColor = const Color(0xFF94A3B8);
    String statusText = "no_status";

     if (status == 'pending') {
      statusText = "new";
      bannerColor = const Color.fromARGB(137, 16, 185, 69);
    } else if (status == 'confirmed') {
      statusText = "in_confirmed";
      bannerColor = const Color(0xFF10B981);
    } else if (status == 'processing') {
      statusText = "in_processing";
      bannerColor = const Color(0xFFF59E0B);
    } else if (status == 'searching') {
      statusText = "in_searching";
      bannerColor = const Color(0xFFF59E0B);
    } else if (status == 'shipped') {
      statusText = "in_Shopping";
      bannerColor = const Color(0xFF3B82F6);
    } else if (status == 'delivered') {
      statusText = "completed";
      bannerColor = const Color(0xFF64748B);
    } else if (status == 'cancelled') {
      statusText = "cancelled";
      bannerColor = const Color(0xFFEF4444);
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: bannerColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bannerColor, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "order_status".tr,
            style: const TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: bannerColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              statusText.tr,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String status, Map order) {
    String label = "reorder".tr;
    IconData icon = Icons.refresh_rounded;

    if (status == 'pending' || status == 'processing') {
      label = "complete_order_process".tr;
      icon = Icons.arrow_forward_rounded;
    }

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () {
          if (status == 'cancelled') {
            // Logic to add elements back into cart and redirect to checkout
          } else {
            // Logic to complete payment/checkout flow
          }
        },
        icon: Icon(icon, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }
}
