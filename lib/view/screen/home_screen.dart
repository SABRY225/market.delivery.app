import 'package:delivery/routes.dart';
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
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: controller.ordersList.isNotEmpty
                        ? ListView.builder(
                            key: const ValueKey('orders_list_active'),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            itemCount: controller.ordersList.length,
                            itemBuilder: (context, index) {
                              final order = controller.ordersList[index];
                              print("order:${order["id"]}");
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "طلب رقم #${order["id"] ?? ''}",
                                              style: const TextStyle(
                                                color: textColor,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              order["date"] ?? "",
                                              style: const TextStyle(
                                                color: Color(0xFF64748B),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            // 💡 استخدام toNamed بدلاً من offNamed وتمرير كائن الـ order الحالي في الـ arguments
                                            Get.toNamed(
                                              AppRoutes.detailesOrder,
                                              arguments: {"orderModel": order},
                                            );
                                          },
                                          style: TextButton.styleFrom(
                                            foregroundColor: primaryColor,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                            ),
                                          ),
                                          child: const Row(
                                            children: [
                                              Text(
                                                "التفاصيل",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(width: 4),
                                              Icon(
                                                Icons.arrow_forward_ios,
                                                size: 12,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      child: Divider(
                                        color: Color(0xFFF1F5F9),
                                        thickness: 1,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "The client:".tr +
                                                    " ${order["customer"]}",
                                                maxLines: 1,
                                                style: const TextStyle(
                                                  color: Color(0xFF64748B),
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            const Text(
                                              "الحساب",
                                              style: TextStyle(
                                                color: Color(0xFF64748B),
                                                fontSize: 11,
                                              ),
                                            ),
                                            Text(
                                              "${order["total"] ?? 0} ج.م",
                                              style: const TextStyle(
                                                color: primaryColor,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
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
                                              onPressed: () {
                                                Get.defaultDialog(
                                                  title: "تأكيد الرفض",
                                                  middleText:
                                                      "هل أنت متأكد من رغبتك في رفض هذا الطلب؟",
                                                  textConfirm: "نعم، ارفض",
                                                  textCancel: "تراجع",
                                                  confirmTextColor:
                                                      Colors.white,
                                                  buttonColor: const Color(
                                                    0xFFEF4444,
                                                  ),
                                                  onConfirm: () {
                                                    controller.rejectOrder(
                                                      order["id"],
                                                    );

                                                    Get.back(); // إغلاق الدايلوج
                                                    Get.back(); // العودة للشاشة السابقة
                                                    Get.snackbar(
                                                      "تم الرفض",
                                                      "تم رفض الطلب بنجاح",
                                                      snackPosition:
                                                          SnackPosition.BOTTOM,
                                                      backgroundColor: Colors
                                                          .red
                                                          .withOpacity(0.1),
                                                      colorText: const Color(
                                                        0xFFEF4444,
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                              style: OutlinedButton.styleFrom(
                                                side: const BorderSide(
                                                  color: Color(0xFFCBD5E1),
                                                ),
                                                foregroundColor: const Color(
                                                  0xFFEF4444,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: const Text(
                                                "رفض الطلب",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: SizedBox(
                                            height: 45,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                Get.defaultDialog(
                                                  title: "تأكيد القبول",
                                                  middleText:
                                                      "هل تريد قبول هذا الطلب وبدء عملية التوصيل؟",
                                                  textConfirm: "تأكيد القبول",
                                                  textCancel: "تراجع",
                                                  confirmTextColor:
                                                      Colors.white,
                                                  buttonColor: primaryColor,
                                                  onConfirm: () {
                                                    controller.acceptOrder(
                                                      order["id"]
                                                    );

                                                    Get.back(); // إغلاق الدايلوج
                                                    Get.back(); // العودة للشاشة السابقة
                                                    Get.snackbar(
                                                      "تم القبول",
                                                      "تم قبول الطلب، بالتوفيق في رحلتك!",
                                                      snackPosition:
                                                          SnackPosition.BOTTOM,
                                                      backgroundColor: Colors
                                                          .green
                                                          .withOpacity(0.1),
                                                      colorText: Colors.green,
                                                    );
                                                  },
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: primaryColor,
                                                foregroundColor: Colors.white,
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: const Text(
                                                "قبول وتوصيل",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          )
                        : Container(
                            key: const ValueKey('orders_list_empty'),
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 60,
                              horizontal: 20,
                            ),
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.02),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.moped_rounded,
                                    size: 48,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "No requests are currently available".tr,
                                  style: TextStyle(
                                    color: Color(0xFF1E293B),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "Stay tuned! New orders will appear here directly."
                                      .tr,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
