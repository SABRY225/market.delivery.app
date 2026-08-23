import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'order_cancel_sheet.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key});

  static Color get primaryColor => const Color(0xFF002AFF);
  static Color get primaryLight => Get.isDarkMode ? const Color(0xFF2D1610) : const Color(0xFFFFF0ED);
  static Color get textColor => Get.isDarkMode ? Colors.white : const Color(0xFF0F172A);
  static Color get subtitleColor => Get.isDarkMode ? Colors.white70 : const Color(0xFF64748B);
  static Color get backgroundColor => Get.theme.scaffoldBackgroundColor;
  static Color get cardColor => Get.isDarkMode ? const Color(0xFF1E293B) : Colors.white;

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      Get.snackbar(
        "Error".tr,
        "Could not call $phoneNumber",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map order = Get.arguments as Map;
    final List items = order["items"] is List ? order["items"] : [];
    final String? phone = order["phone"]?.toString();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        foregroundColor: textColor,
        title: Text(
          "${"Request number #".tr} ${order["id"]}",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: textColor,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          _buildCustomerCard(order, phone),

          const SizedBox(height: 16),

          _sectionCard(
            title: "Appointment Details".tr,
            child: Column(
              children: [
                _infoRow(
                  Icons.access_time_rounded,
                  "Expected delivery time".tr,
                  "${order["deliveryTime"] ?? '-'}",
                ),
                Divider(height: 16, color: Color(0xFFF1F5F9)),
                _infoRow(
                  Icons.calendar_today_outlined,
                  "Order Date".tr,
                  "${order["date"] ?? '-'}",
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          _sectionCard(
            title: "${"Products".tr} (${items.length})",
            child: Column(
              children: items.asMap().entries.map<Widget>((entry) {
                final index = entry.key;
                final item = entry.value;
                return Column(
                  children: [
                    _buildOrderItem(item),
                    if (index < items.length - 1)
                      Divider(height: 20, color: Color(0xFFF1F5F9)),
                  ],
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          _sectionCard(
            title: "Payment Summary".tr,
            child: Column(
              children: [
                _summaryRow(
                  "Payment Method".tr,
                  "${order["payment"] ?? '-'}",
                ),
                _summaryRow(
                  "Delivery Fee".tr,
                  "${order["deliveryFee"] ?? 0} ${"egp".tr}",
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(color: Color(0xFFE2E8F0)),
                ),
                _summaryRow(
                  "Total".tr,
                  "${order["total"] ?? 0} ${"egp".tr}",
                  isBold: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 100), 
        ],
      ),

      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          boxShadow: [
            BoxShadow(
              color: Get.isDarkMode ? Colors.transparent : Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _openCancelSheet(context, order),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    "Cancel Order".tr,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _confirmDelivery(context, order),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    "Deliver Order".tr,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerCard(Map order, String? phone) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Get.isDarkMode ? Colors.transparent : Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: primaryLight,
            child: Icon(Icons.person, color: primaryColor, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "customer_label".tr,
                  style: TextStyle(fontSize: 12, color: subtitleColor),
                ),
                const SizedBox(height: 2),
                Text(
                  "${order["customer"] ?? '-'}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: textColor,
                  ),
                ),
                if (phone != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    phone,
                    style: TextStyle(fontSize: 13, color: subtitleColor),
                  ),
                ],
              ],
            ),
          ),
          if (phone != null && phone.isNotEmpty)
            InkWell(
              onTap: () => _makePhoneCall(phone),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.phone,
                  color: Color(0xFF10B981),
                  size: 22,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(Map item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${item["name"] ?? ''}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.storefront_outlined, size: 14, color: subtitleColor),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      "${item["vendorName"] ?? ''} • ${item["vendorArea"] ?? ''}",
                      style: TextStyle(
                        fontSize: 12,
                        color: subtitleColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Text(
          "${item["price"] ?? 0} ${"egp".tr}",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: primaryColor,
          ),
        ),
      ],
    );
  }

  void _confirmDelivery(BuildContext context, Map order) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Confirm Delivery".tr),
        content: Text(
          "Are you sure you delivered order #${order["id"]}?".tr,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Back".tr, style: TextStyle(color: subtitleColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Get.back(); 
              Get.back(); 
            },
            child: Text(
              "Confirm".tr,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _openCancelSheet(BuildContext context, Map order) {
    Get.bottomSheet(
      OrderCancelSheet(order: order),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Get.isDarkMode ? Colors.transparent : Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: subtitleColor),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(color: subtitleColor, fontSize: 13),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: textColor,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isBold ? textColor : subtitleColor, fontSize: isBold ? 14 : 13, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(
            value,
            style: TextStyle(
              color: isBold ? primaryColor : textColor,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              fontSize: isBold ? 16 : 13,
            ),
          ),
        ],
      ),
    );
  }
}