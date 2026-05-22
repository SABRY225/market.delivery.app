import 'package:delivery/view/widget/home/OrderDeliveryCard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/home_controller.dart';
import '../../../core/class/status_request.dart';
import '../widget/home/_buildSectionTitle.dart';
import '../widget/home/_buildBottomNav.dart';
import '../widget/home/DriverStatusCard.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const Color primaryColor = Color(0xFFFF5722);
  static const Color textColor = Color(0xFF1E293B);
  static const Color backgroundColor = Color.fromARGB(255, 238, 236, 236);

  @override
  Widget build(BuildContext context) {
    Get.put(HomeController());

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          "ready_orders".tr,
          style: const TextStyle(
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: GetBuilder<HomeController>(
        builder: (controller) {
          if (controller.statusRequest == StatusRequest.loading) {
            return const Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          } else if (controller.statusRequest == StatusRequest.offlinefailure) {
            return Center(
              child: Text(
                "no_internet_connection".tr,
                style: const TextStyle(color: textColor),
              ),
            );
          } else if (controller.statusRequest == StatusRequest.serverfailure) {
            return Center(
              child: Text(
                "server_error".tr,
                style: const TextStyle(color: textColor),
              ),
            );
          } else {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildSectionTitle("driver_status".tr),
                  DriverStatusCard(
                    isOnline: controller.isAvailable,
                    onStatusChanged: (value) {
                      controller.toggleStatus(value);
                    },
                  ),
                  buildSectionTitle("Orders ready for delivery".tr),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.ordersList.length,
                    itemBuilder: (context, index) {
                      final order = controller.ordersList[index];
                      return OrderDeliveryCard(
                        orderId: order.id.toString(),
                        totalPrice: order.price.toString(),
                        orderTime: order.time.toString(),
                        pickupLocation: order.storeName,
                        deliveryLocation: order.customerAddress,
                        onDetailsPressed: () {
                          Get.toNamed(
                            "/order_details",
                            arguments: {"orderModel": order},
                          );
                        },
                        onAcceptPressed: () {
                          controller.acceptOrder(order.id);
                        },
                        onRejectPressed: () {
                          controller.rejectOrder(order.id);
                        },
                      );
                    },
                  ),
                ],
              ),
            );
          }
        },
      ),
      bottomNavigationBar: buildBottomNav(context, 0),
    );
  }
}
