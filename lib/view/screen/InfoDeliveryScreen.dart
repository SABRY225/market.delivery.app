import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/info_delivery_controller.dart';
import '../../../core/class/status_request.dart';

class InfoDeliveryScreen extends StatelessWidget {
  const InfoDeliveryScreen({super.key});

  static const Color primaryColor = Color(0xFFFF5722); 
  static const Color textColor = Color(0xFF1E293B);    
  static const Color iconColor = Color(0xFF64748B);    
  static const Color backgroundColor = Color.fromARGB(255, 238, 236, 236);

  @override
  Widget build(BuildContext context) {
    Get.put(InfoDeliveryController());

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          "info_delivery".tr,
          style: const TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: textColor),
          onPressed: () => Get.back(),
        ),
      ),
      body: GetBuilder<InfoDeliveryController>(
        builder: (controller) {
          if (controller.statusRequest == StatusRequest.loading) {
            return const Center(child: CircularProgressIndicator(color: primaryColor));
          } else if (controller.statusRequest == StatusRequest.offlinefailure) {
            return Center(child: Text("no_internet_connection".tr, style: const TextStyle(color: textColor)));
          } else if (controller.statusRequest == StatusRequest.serverfailure) {
            return Center(child: Text("server_error".tr, style: const TextStyle(color: textColor)));
          } else {
            final data = controller.driverData;
            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20.0),
              children: [
                _buildHeaderProfileCard(data),
                const SizedBox(height: 25),
                _buildSectionTitle("Account information is personal".tr),
                _buildInfoGroup([
                  _buildDetailTile(Icons.email_outlined, "e-mail".tr, data["email"]),
                  _buildDetailTile(Icons.phone_android_outlined, "phone number".tr, data["phone"]),
                  _buildDetailTile(Icons.chat_bubble_outline_rounded, "WhatsApp".tr, data["whatsapp"]),
                  _buildDetailTile(Icons.cake_outlined, "date of birth", data["dob"]),
                  _buildDetailTile(Icons.person_outline, "Sex".tr, data["gender"] == "male" ? "male".tr : "feminine".tr),
                ]),
                const SizedBox(height: 25),
                _buildSectionTitle("Vehicle data".tr),
                _buildInfoGroup([
                  _buildDetailTile(Icons.two_wheeler_outlined,"Vehicle type".tr , data["vehicleType"]),
                  _buildDetailTile(Icons.color_lens_outlined, "Vehicle color".tr, data["vehicleColor"]),
                  _buildDetailTile(Icons.badge_outlined,"License plate number".tr, data["plateNumber"]),
                ]),
                const SizedBox(height: 25),
                _buildSectionTitle("Validity of documents and work".tr),
                _buildInfoGroup([
                  _buildDetailTile(Icons.calendar_month_outlined,"Identity expiry".tr, data["idExpiry"]),
                  _buildDetailTile(Icons.credit_card_outlined,"License Expiration".tr , data["licenseExpiry"]),
                  _buildDetailTile(Icons.assignment_outlined,"Vehicle license".tr, data["vehicleLicenseExpiry"]),
                  _buildDetailTile(Icons.map_outlined, "Operating Area".tr, data["operatingArea"]),
                  _buildDetailTile(Icons.work_outline,"Type of work".tr, data["workType"] == "full_time" ?"Full-time".tr : "partial".tr),
                ]),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4, right: 4),
      child: Text(
        title,
        style: const TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildHeaderProfileCard(Map<String, dynamic> data) {
    final bool isVerified = data["accountStatus"]=="approved" ? true:false;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: textColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.white.withOpacity(0.1),
            child: const Icon(Icons.person, color: Colors.white, size: 35),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data["username"] ?? "",
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isVerified ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isVerified ? "Verified" : "unVerified",
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: primaryColor, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            data["rating"] ?? "0.0",
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailTile(IconData icon, String label, String? value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: iconColor, fontSize: 14)),
          const Spacer(),
          Text(
            value ?? "nothing".tr,
            style: const TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
