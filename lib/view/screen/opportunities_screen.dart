import 'package:delivery/controller/opportunities_controller.dart';
import 'package:delivery/core/class/status_request.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OpportunitiesScreen extends StatelessWidget {
  const OpportunitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(OpportunitiesController());
    final isDark = Get.isDarkMode;
    final bgColor = Get.theme.scaffoldBackgroundColor;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final titleColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          "challenges_and_opportunities".tr,
          style: TextStyle(
            color: titleColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: cardColor,
        elevation: 0,
        iconTheme: IconThemeData(color: titleColor),
      ),
      body: GetBuilder<OpportunitiesController>(
        builder: (controller) {
          if (controller.statusRequest == StatusRequest.loading) {
            return Center(child: CircularProgressIndicator(color: Color(0xFFFF5722)));
          } else if (controller.statusRequest == StatusRequest.failure || controller.data.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.emoji_events_outlined, size: 80, color: Colors.grey.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text(
                    "no_challenges_available".tr,
                    style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text("stay_tuned_for_challenges".tr, style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          } else {
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: controller.data.length,
              itemBuilder: (context, index) {
                var opp = controller.data[index];
                return _buildChallengeCard(context, opp, controller);
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildChallengeCard(BuildContext context, Map opp, OpportunitiesController controller) {
    final isDark = Get.isDarkMode;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white70 : Colors.grey.shade600;
    final innerBgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final innerIconBg = isDark ? const Color(0xFF2D1610) : const Color(0xFFFFF0EC);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.transparent : Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // شريط زينة جانبي ليعطي طابع أنيق
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 6,
              decoration: const BoxDecoration(
                color: Color(0xFFFF5722),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: innerIconBg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.rocket_launch_rounded, color: Color(0xFFFF5722), size: 26),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            opp['title'] ?? 'bonus_opportunity'.tr,
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "extra_task_to_increase_profits".tr,
                            style: TextStyle(
                              color: subTextColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (opp['description'] != null) ...[
                  Text(
                    opp['description'],
                    style: TextStyle(color: subTextColor, fontSize: 13, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                ],
                // معلومات الوقت والتاريخ والعائد المالي
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: innerBgColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade100),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey),
                              SizedBox(width: 4),
                              Text("time_and_date".tr, style: TextStyle(color: Colors.grey, fontSize: 11)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "${opp['date'] ?? '-'}",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textColor),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "${opp['start_time'] ?? '-'} ${'to_word'.tr} ${opp['end_time'] ?? '-'}",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: textColor),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text("extra_revenue".tr, style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(
                              "+${opp['reward']} ${'currency'.tr}",
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5722),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () => controller.acceptOpportunity(opp['id'].toString()),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "accept_opportunity".tr,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
