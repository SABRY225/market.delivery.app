import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DriverStatusCard extends StatelessWidget {
  final bool isOnline;
  final ValueChanged<bool> onStatusChanged;

  const DriverStatusCard({
    super.key,
    required this.isOnline,
    required this.onStatusChanged,
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isOnline ? primaryColor.withOpacity(0.1) : const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isOnline ? Icons.electric_bike_rounded : Icons.moped_outlined,
              color: isOnline ? primaryColor : subTextColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isOnline ? "available_for_work".tr : "currently_unavailable".tr,
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isOnline ? "you_will_receive_delivery_requests_now".tr : "turn_on_to_receive_orders".tr,
                  style: const TextStyle(
                    color: subTextColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: isOnline,
            onChanged: onStatusChanged,
            activeColor: Colors.white,
            activeTrackColor: primaryColor,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFCBD5E1),
          ),
        ],
      ),
    );
  }
}
