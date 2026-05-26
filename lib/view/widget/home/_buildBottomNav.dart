import 'package:delivery/controller/home_controller.dart';
import 'package:delivery/controller/order/order_controller.dart';
import '../../../routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget buildBottomNav(BuildContext context, int currentTabsIndex) {
  final HomeController homeController = Get.find<HomeController>();
  final OrderController orderController = Get.find<OrderController>();

  const Color activeColor = Color(0xFFFF5722); 
  const Color inactiveColor = Color(0xFF94A3B8);  
  const Color darkBlue = Color(0xFF1E293B);

  return GetBuilder<HomeController>(
    builder: (controller) {
      final int currentOrdersCount = orderController.orderCounts ?? 0;
      final int readyOrdersCount = homeController.orderReadyCont ?? 0;

      return Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16), 
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24), 
          boxShadow: [
            BoxShadow(
              color: darkBlue.withOpacity(0.08),
              spreadRadius: 2,
              blurRadius: 20,
              offset: const Offset(0, 8), 
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // 1. أيقونة الطلبات الجاهزة
            _buildNavItem(
              index: 0,
              currentIndex: currentTabsIndex,
              icon: Icons.assignment_turned_in_outlined,
              activeIcon: Icons.assignment_turned_in,
              label: "ready_orders".tr,
              activeColor: activeColor,
              inactiveColor: inactiveColor,
              badgeCount: readyOrdersCount, 
              onTap: () => Get.toNamed(AppRoutes.home),
            ),

            // 2. أيقونة الطلبات الحالية
            _buildNavItem(
              index: 1,
              currentIndex: currentTabsIndex,
              icon: Icons.local_shipping_outlined,
              activeIcon: Icons.local_shipping,
              label: "current_orders".tr,
              activeColor: activeColor,
              inactiveColor: inactiveColor,
              badgeCount: currentOrdersCount, 
              onTap: () => Get.toNamed(AppRoutes.orders),
            ),

            // 3. أيقونة الحساب الشخصي
            _buildNavItem(
              index: 2,
              currentIndex: currentTabsIndex,
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              label: "profile".tr,
              activeColor: activeColor,
              inactiveColor: inactiveColor,
              onTap: () => Get.toNamed(AppRoutes.profile),
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildNavItem({
  required int index,
  required int currentIndex,
  required IconData icon,
  required IconData activeIcon,
  required String label,
  required Color activeColor,
  required Color inactiveColor,
  required VoidCallback onTap,
  int badgeCount = 0,
}) {
  final bool isSelected = index == currentIndex;

  return Expanded(
    child: InkWell(
      onTap: onTap,
      splashColor: Colors.transparent, 
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(vertical: 4),
            transform: isSelected ? (Matrix4.identity()..scale(1.15)) : Matrix4.identity(),
            child: Badge(
              label: Text(
                "$badgeCount",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
              isLabelVisible: badgeCount > 0,
              backgroundColor: activeColor,
              largeSize: 16,
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? activeColor : inactiveColor,
                size: 24,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF1E293B) : inactiveColor,
              fontSize: isSelected ? 11 : 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 4,
            width: isSelected ? 16 : 0, 
            decoration: BoxDecoration(
              color: activeColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    ),
  );
}