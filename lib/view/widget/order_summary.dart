import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderSummary extends StatelessWidget {
  final dynamic itemPrice;
  final dynamic shippingPrice;
  final int quantity;

  const OrderSummary({
    super.key,
    required this.itemPrice,
    required this.shippingPrice,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    double price = double.tryParse(itemPrice.toString()) ?? 0;
    double shipping = double.tryParse(shippingPrice.toString()) ?? 0;
    double subtotal = price * quantity;
    double total = subtotal + shipping;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          _buildRow(
            "Subtotal".tr + "($quantity " + "items".tr + ")",
            "${subtotal.toStringAsFixed(2)} " + "egp".tr,
          ),
          _buildRow(
            "Shipping Fee".tr,
            "${shipping.toStringAsFixed(2)} " + "egp".tr,
          ),
          const Divider(color: Colors.white10, height: 20),
          _buildRow(
            "Total Amount".tr,
            "${total.toStringAsFixed(2)} " + "egp".tr,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isTotal ? Colors.white : Colors.grey,
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isTotal ? Colors.blueAccent : Colors.white,
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
