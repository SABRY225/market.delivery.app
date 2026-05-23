import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart'; // لتفعيل الاتصال الهاتفي والخرائط

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key});

  static const Color primaryColor = Color(0xFFFF5722);
  static const Color textColor = Color(0xFF1E293B);
  static const Color subTextColor = Color(0xFF64748B);
  static const Color backgroundColor = Color(0xFFF8FAFC);

  // دالة مساعدة لفتح الاتصال الهاتفي
  Future<void> _makeCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      Get.snackbar("خطأ", "لا يمكن إجراء المكالمة الآن");
    }
  }

  // دالة مساعدة لفتح الموقع على خرائط جوجل
  Future<void> _openMap(String? lat, String? lng) async {
    if (lat == null || lng == null) return;
    final Uri googleMapUri = Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");
    if (await canLaunchUrl(googleMapUri)) {
      await launchUrl(googleMapUri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar("خطأ", "لا يمكن فتح الخرائط");
    }
  }

  @override
  Widget build(BuildContext context) {
    // استقبال بيانات الطلب الممررة عبر الـ Navigator (GetX)
    final Map<String, dynamic>? args = Get.arguments as Map<String, dynamic>?;
    var order = args?['orderModel'];

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("تفاصيل الطلب")),
        body: const Center(child: Text("خطأ في تحميل بيانات الطلب")),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl, // دعم الواجهة العربية
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: Text(
            "طلب رقم #${order["id"]}",
            style: const TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: textColor, size: 20),
            onPressed: () => Get.back(),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. بطاقة معلومات المتجر (نقطة الاستلام)
              if (order['items'] != null && (order["items"] as List).isNotEmpty) ...[
                _buildSectionTitle("بيانات المتجر (الاستلام)"),
                // 💡 الإصلاح هنا: نمرر العنصر الأول [0] من القائمة مباشرة للكارت
                _buildVendorCard(order["items"][0]),
                const SizedBox(height: 16),
              ],

              // 2. بطاقة معلومات العميل (نقطة التسليم)
              _buildSectionTitle("بيانات العميل (التسليم)"),
              _buildCustomerCard(order),
              const SizedBox(height: 16),

              // 3. قائمة المنتجات المطلوبة
              _buildSectionTitle("المنتجات"),
              _buildItemsList(order),
              const SizedBox(height: 16),

              // 4. الفاتورة وملخص الحساب
              _buildSectionTitle("ملخص الحساب"),
              _buildInvoiceCard(order),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, right: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          color: textColor,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // كارت المتجر
  Widget _buildVendorCard(dynamic item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFF1F5F9),
                child: Icon(Icons.storefront, color: primaryColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item["vendorName"] ?? "اسم المتجر",
                      style: const TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${item["vendorCity"] ?? ''} - ${item["vendorArea"] ?? ''}",
                      style: const TextStyle(color: subTextColor, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: Color(0xFFF1F5F9)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionButton(
                icon: Icons.phone_in_talk,
                label: "اتصال",
                color: Colors.blue,
                onTap: () => _makeCall(item["vendorPhoneNumber"] ?? ""),
              ),
              _buildActionButton(
                icon: Icons.map,
                label: "الموقع على الخريطة",
                color: Colors.green,
                onTap: () => _openMap(item["vendorLatitude"], item["vendorLongitude"]),
              ),
            ],
          )
        ],
      ),
    );
  }

  // كارت العميل
  Widget _buildCustomerCard(var order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFF1F5F9),
                child: Icon(Icons.person_outline, color: textColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order["customer"] ?? "اسم العميل",
                      style: const TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "تاريخ الطلب: ${order["date"] ?? ''}",
                      style: const TextStyle(color: subTextColor, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: Color(0xFFF1F5F9)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionButton(
                icon: Icons.phone,
                label: "اتصال بالعميل",
                color: Colors.blue,
                onTap: () => _makeCall(order["phone"] ?? ""),
              ),
              _buildActionButton(
                icon: Icons.navigation_outlined,
                label: "موقع التوصيل",
                color: primaryColor,
                onTap: () => _openMap(order["latitude"], order["longitude"]),
              ),
            ],
          )
        ],
      ),
    );
  }

  // عرض المنتجات
  Widget _buildItemsList(var order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: order["items"]?.length ?? 0,
        separatorBuilder: (context, index) => const Divider(height: 20, color: Color(0xFFF1F5F9)),
        itemBuilder: (context, index) {
          final item = order["items"][index];
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.fastfood_outlined, color: primaryColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    item["name"] ?? "",
                    style: const TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Text(
                "${item["price"] ?? 0} ج.م",
                style: const TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          );
        },
      ),
    );
  }

  // تفاصيل الفاتورة
  Widget _buildInvoiceCard(var order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildInvoiceRow("طريقة الدفع", order["payment"] == "cod" ? "كاش عند الاستلام" : order["payment"] ?? ""),
          const SizedBox(height: 10),
          _buildInvoiceRow("مصاريف التوصيل", "${order["deliveryFee"] ?? 0} ج.م"),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Color(0xFFF1F5F9), thickness: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "الإجمالي الكلي",
                style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                "${order["total"] ?? 0} ج.م",
                style: const TextStyle(color: primaryColor, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: subTextColor, fontSize: 14)),
        Text(value, style: const TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }

  // زِر إجراء الاتصال أو الخريطة الفرعي
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}