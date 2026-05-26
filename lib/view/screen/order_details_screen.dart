import 'package:delivery/controller/order/order_details_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key});

  static const Color primaryColor = Color(0xFFFF5722);
  static const Color textColor = Color(0xFF1E293B);
  static const Color iconColor = Color(0xFF64748B);
  static const Color backgroundColor = Color.fromARGB(255, 238, 236, 236);

  // دالة لجلب موقع الديليفري الحالي وحساب المسافة
  Future<Map<String, dynamic>> _getDeliveryLocationAndDistance(
    LatLng customerLoc,
  ) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return {'distance': 'loc_service_disabled'.tr, 'position': null};
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return {'distance': 'loc_permission_denied'.tr, 'position': null};
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return {'distance': 'loc_permission_forever_denied'.tr, 'position': null};
    }

    Position currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    double distanceInMeters = Geolocator.distanceBetween(
      currentPosition.latitude,
      currentPosition.longitude,
      customerLoc.latitude,
      customerLoc.longitude,
    );

    String formattedDistance;
    if (distanceInMeters >= 1000) {
      double distanceInKm = distanceInMeters / 1000;
      formattedDistance = "${distanceInKm.toStringAsFixed(2)} ${'km'.tr}";
    } else {
      formattedDistance = "${distanceInMeters.toStringAsFixed(0)} ${'meter'.tr}";
    }

    return {
      'distance': formattedDistance,
      'position': LatLng(currentPosition.latitude, currentPosition.longitude),
    };
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      Get.snackbar("error_title".tr, "cannot_call_now".tr);
    }
  }

  void _showCancelDialog(String orderId, OrderDetailsController controller) {
    final TextEditingController reasonController = TextEditingController();

    Get.defaultDialog(
      title: "cancel_reason_title".tr,
      titleStyle: const TextStyle(
        color: textColor,
        fontWeight: FontWeight.bold,
      ),
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: TextField(
          controller: reasonController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: "cancel_reason_hint".tr,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
      textConfirm: "confirm_cancel".tr,
      textCancel: "back".tr,
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        if (reasonController.text.trim().isEmpty) {
          Get.snackbar("warning_title".tr, "please_write_reason".tr);
        } else {
          Get.back();
          await controller.cancelOrder(
            orderId,
            reasonController.text.trim(),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final OrderDetailsController controller = Get.put(OrderDetailsController());

    final Map orderData = Get.arguments?['orderData'] ?? {};
    String orderId = orderData['id']?.toString() ?? "";
    String customerName = orderData['customer'] ?? "unknown_customer".tr;
    String customerPhone = orderData['phone']?.toString() ?? "";

    double lat =
        double.tryParse(orderData['location']?[1]?.toString() ?? "") ??
        30.0596113;
    double lng =
        double.tryParse(orderData['location']?[0]?.toString() ?? "") ??
        31.1884236;

    final LatLng customerLocation = LatLng(lat, lng);

    final CameraPosition initialCameraPosition = CameraPosition(
      target: customerLocation,
      zoom: 16.0,
    );

    String total = orderData['total']?.toString() ?? "0";
    String status = orderData['status'] ?? "pending";
    String startTime = orderData['startTime'] ?? "";
    String paymentMethod = orderData['payment'] ?? "cash";
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
            _buildStatusBanner(status),
            const SizedBox(height: 16),

            _buildSectionCard(
              title: "customer_info".tr,
              icon: Icons.person_outline,
              child: Column(
                children: [
                  _buildDetailRow("client_name".tr, customerName),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "phone_number".tr,
                            style: const TextStyle(
                              color: iconColor,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            customerPhone.isEmpty ? "not_registered".tr : customerPhone,
                            style: const TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (customerPhone.isNotEmpty)
                        IconButton(
                          icon: const Icon(
                            Icons.phone_forwarded,
                            color: Colors.green,
                            size: 28,
                          ),
                          onPressed: () => _makePhoneCall(customerPhone),
                        ),
                    ],
                  ),
                  const Divider(height: 20),
                  _buildDetailRow("time".tr, startTime),
                  const Divider(height: 20),
                  _buildDetailRow(
                    "payment".tr,
                    paymentMethod.toLowerCase().tr,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // كارت عرض الخريطة الأكبر مع رسم مسار تفاعلي وإمكانيات تحكم كاملة
            FutureBuilder<Map<String, dynamic>>(
              future: _getDeliveryLocationAndDistance(customerLocation),
              builder: (context, snapshot) {
                String distanceText = "calculating_route".tr;
                LatLng? deliveryLocation;

                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  distanceText = snapshot.data!['distance'];
                  deliveryLocation = snapshot.data!['position'];
                }

                Set<Marker> mapMarkers = {
                  Marker(
                    markerId: const MarkerId('customer_loc'),
                    position: customerLocation,
                    infoWindow: InfoWindow(
                      title: customerName,
                      snippet: 'delivery_destination_snippet'.tr,
                    ),
                  ),
                };

                // إعداد قائمة الخطوط المتصلة (Polyline) لرسم المسار
                Set<Polyline> mapPolylines = {};

                if (deliveryLocation != null) {
                  mapMarkers.add(
                    Marker(
                      markerId: const MarkerId('delivery_loc'),
                      position: deliveryLocation,
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueBlue,
                      ),
                      infoWindow: InfoWindow(
                        title: 'my_current_location'.tr,
                        snippet: 'delivery_driver'.tr,
                      ),
                    ),
                  );

                  // رسم خط مباشر واضح يربط بين الديليفري والعميل على الخريطة
                  mapPolylines.add(
                    Polyline(
                      polylineId: const PolylineId('route_to_customer'),
                      points: [deliveryLocation, customerLocation],
                      color: primaryColor, // لون الخط برتقالي متناسق مع التطبيق
                      width: 5, // سمك الخط ليكون واضحاً
                      geodesic: true,
                    ),
                  );
                }

                return _buildSectionCard(
                  title: "delivery_location_route".tr,
                  icon: Icons.map_outlined,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "current_distance_to_client".tr,
                            style: const TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              distanceText,
                              style: const TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          height: 320, // تم تكبير الارتفاع من 200 إلى 320 لتصبح الخريطة ضخمة ومريحة للعين
                          width: double.infinity,
                          child: GoogleMap(
                            initialCameraPosition: initialCameraPosition,
                            mapType: MapType.normal,

                            // تفعيل كافة مميزات التحكم الكامل بالخريطة
                            myLocationButtonEnabled: true, // زر الانتقال للموقع الحالي
                            zoomControlsEnabled: true, // أزرار التكبير والتصغير (+ / -)
                            zoomGesturesEnabled: true, // السماح بالتكبير بإصبعين
                            scrollGesturesEnabled: true, // السماح بسحب الخريطة والتحرك فيها
                            tiltGesturesEnabled: true, // السماح بإمالة الخريطة بأبعاد ثلاثية
                            rotateGesturesEnabled: true, // السماح بتدوير الخريطة

                            markers: mapMarkers,
                            polylines: mapPolylines, // تمرير خط المسار للخريطة
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            _buildSectionCard(
              title: "order_items".tr,
              icon: Icons.shopping_basket_outlined,
              child: items.isEmpty
                  ? Center(child: Text("order_without_products".tr))
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const Divider(height: 20),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        String name = item['name'] ?? "product_without_name".tr;
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

            _buildSectionCard(
              title: "receipt_summary".tr,
              icon: Icons.receipt_long_outlined,
              child: Row(
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
            ),
            const SizedBox(height: 32),

            _buildActionButtonsRow(status, orderId, controller),
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
      statusText = "in_shopping";
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

  Widget _buildActionButtonsRow(
    String status,
    String orderId,
    OrderDetailsController controller,
  ) {
    if (status == 'delivered' || status == 'cancelled') {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () => _showCancelDialog(orderId, controller),
              icon: const Icon(Icons.cancel_outlined, color: Colors.red),
              label: Text(
                "cancel_order".tr,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () async {
                await controller.deliverOrder(orderId);
              },
              icon: const Icon(Icons.check_circle_outline, color: Colors.white),
              label: Text(
                "deliver_order".tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}