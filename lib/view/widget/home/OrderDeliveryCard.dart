import 'package:flutter/material.dart';

class OrderDeliveryCard extends StatelessWidget {
  final String orderId;
  final String totalPrice;
  final String orderTime;
  final String pickupLocation;
  final String deliveryLocation;
  final VoidCallback onDetailsPressed;
  final VoidCallback onAcceptPressed;
  final VoidCallback onRejectPressed;

  const OrderDeliveryCard({
    super.key,
    required this.orderId,
    required this.totalPrice,
    required this.orderTime,
    required this.pickupLocation,
    required this.deliveryLocation,
    required this.onDetailsPressed,
    required this.onAcceptPressed,
    required this.onRejectPressed
  });

  static const Color primaryColor = Color(0xFFFF5722);
  static const Color textColor = Color(0xFF1E293B);
  static const Color subTextColor = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            spreadRadius: 0,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "طلب رقم #$orderId",
                    style: const TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    orderTime,
                    style: const TextStyle(color: subTextColor, fontSize: 12),
                  ),
                ],
              ),
              TextButton(
                onPressed: onDetailsPressed,
                style: TextButton.styleFrom(
                  foregroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Row(
                  children: [
                    Text("التفاصيل", style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios, size: 12),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(color: Color(0xFFF1F5F9), thickness: 1),
          ),
          Row(
            children: [
              Column(
                children: [
                  const Icon(Icons.circle, color: primaryColor, size: 14),
                  Container(
                    width: 2,
                    height: 30,
                    color: const Color(0xFFCBD5E1),
                  ),
                  const Icon(Icons.location_on, color: textColor, size: 16),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pickupLocation,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      deliveryLocation,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: subTextColor, fontSize: 14),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text("الحساب", style: TextStyle(color: subTextColor, fontSize: 11)),
                  Text(
                    "$totalPrice ج.م",
                    style: const TextStyle(color: primaryColor, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 45,
                  child: OutlinedButton(
                    onPressed: onRejectPressed,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      foregroundColor: const Color(0xFFEF4444),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("رفض الطلب", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 45,
                  child: ElevatedButton(
                    onPressed: onAcceptPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("قبول وتوصيل", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
