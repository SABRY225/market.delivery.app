import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/trip_details_controller.dart';
import '../../core/class/status_request.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/datasource/remote/home_data.dart';

class TripDetailsScreen extends StatelessWidget {
  const TripDetailsScreen({super.key});

  static Color get primaryColor => const Color(0xFF002AFF);
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
    Get.put(TripDetailsController(homeData: HomeData(Get.find())));
    return GetBuilder<TripDetailsController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            backgroundColor: backgroundColor,
            elevation: 0,
            centerTitle: true,
            foregroundColor: textColor,
            title: Text(
              "${"Trip Details".tr} #${controller.tripId}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: textColor,
              ),
            ),
          ),
          body: _buildBody(controller),
        );
      }
    );
  }

  Widget _buildBody(TripDetailsController controller) {
    if (controller.statusRequest == StatusRequest.loading) {
      return Center(child: CircularProgressIndicator(color: primaryColor));
    } else if (controller.statusRequest == StatusRequest.failure ||
               controller.statusRequest == StatusRequest.serverfailure ||
               controller.statusRequest == StatusRequest.offlinefailure) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: subtitleColor),
            const SizedBox(height: 16),
            Text(
              "Error fetching trip details".tr,
              style: TextStyle(color: textColor, fontSize: 16),
            ),
            TextButton(
              onPressed: () => controller.getTripDetails(),
              child: Text("Retry".tr, style: TextStyle(color: primaryColor)),
            )
          ],
        ),
      );
    }

    final trip = controller.tripDetails;
    if (trip.isEmpty) return const SizedBox();

    final customer = trip['customer'] ?? {};
    final user = customer['user'] ?? {};
    final String customerName = user['name'] ?? 'Unknown customer';
    final String? phone = customer['phone']?.toString();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      children: [
        _buildCustomerCard(customerName, phone),
        const SizedBox(height: 16),

        _sectionCard(
          title: "Trip Route".tr,
          child: Column(
            children: [
              _infoRow(
                Icons.my_location_rounded,
                "Pickup point".tr,
                "${trip["pickupAddress"] ?? 'Not Specified'}",
                color: Colors.blue,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: SizedBox(
                  height: 20,
                  child: VerticalDivider(color: Colors.grey, thickness: 1),
                ),
              ),
              _infoRow(
                Icons.location_on_rounded,
                "Drop-off point".tr,
                "${trip["dropoffAddress"] ?? 'Not Specified'}",
                color: Colors.red,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        _sectionCard(
          title: "Trip Information".tr,
          child: Column(
            children: [
              _infoRow(
                Icons.attach_money_rounded,
                "Fare".tr,
                "${trip["fareAmount"] ?? '0'} ${"EGP".tr}",
              ),
              Divider(height: 24, color: Colors.grey.withOpacity(0.2)),
              _infoRow(
                Icons.payment_rounded,
                "Payment Method".tr,
                "${trip["paymentMethod"] ?? '-'}",
              ),
              Divider(height: 24, color: Colors.grey.withOpacity(0.2)),
              _infoRow(
                Icons.route_rounded,
                "Distance".tr,
                "${trip["distanceKm"] ?? '-'} km",
              ),
              Divider(height: 24, color: Colors.grey.withOpacity(0.2)),
              _infoRow(
                Icons.info_outline_rounded,
                "Status".tr,
                "${trip["status"] ?? '-'}",
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerCard(String customerName, String? phone) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Get.isDarkMode ? Colors.white12 : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: primaryColor.withOpacity(0.1),
            child: Icon(Icons.person_rounded, color: primaryColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customerName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
                if (phone != null)
                  Text(
                    phone,
                    style: TextStyle(
                      color: subtitleColor,
                      fontSize: 13,
                    ),
                  ),
              ],
            ),
          ),
          if (phone != null)
            InkWell(
              onTap: () => _makePhoneCall(phone),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.call_rounded,
                  color: Colors.green,
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Get.isDarkMode ? Colors.white12 : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color ?? subtitleColor),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: subtitleColor,
            fontSize: 13,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}