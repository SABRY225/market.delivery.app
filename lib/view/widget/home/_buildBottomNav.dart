import '../../../controller/cart_controller.dart';
import '../../../routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget buildBottomNav(BuildContext context, int currentTabsIndex) {
  Get.put(CartController());

  const Color primaryColor = Color(0xFFFF5722);   
  const Color activeColor = Color(0xFF1E293B);    
  const Color inactiveColor = Color(0xFF94A3B8);  

  return GetBuilder<CartController>(
    builder: (controller) => BottomNavigationBar(
      backgroundColor: Colors.white, 
      selectedItemColor: activeColor, 
      unselectedItemColor: inactiveColor, 
      currentIndex: currentTabsIndex, 
      type: BottomNavigationBarType.fixed,
      elevation: 20, 
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      unselectedLabelStyle: const TextStyle(fontSize: 11),
      items: [
        BottomNavigationBarItem(
          icon: Badge(
            label: Text(
              "${controller.cartCount}",
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            ),
            isLabelVisible: controller.cartCount > 0, 
            backgroundColor: primaryColor, 
            child: const Icon(Icons.assignment_turned_in_outlined), 
          ),
          activeIcon: const Icon(Icons.assignment_turned_in), 
          label: "ready_orders".tr,
        ),
        BottomNavigationBarItem(
          icon: Badge(
            label: Text(
              "${controller.cartCount}", 
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            ),
            isLabelVisible: controller.cartCount > 0, 
            backgroundColor: primaryColor,
            child: const Icon(Icons.local_shipping_outlined), 
          ),
          activeIcon: const Icon(Icons.local_shipping),
          label: "current_orders".tr,
        ),

        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline), 
          activeIcon: Icon(Icons.person), 
          label: "profile",
        ),
      ],
      onTap: (index) {
        if (index == 0) Get.toNamed(AppRoutes.home);
        if (index == 1) Get.toNamed(AppRoutes.orders);
        if (index == 2) Get.toNamed(AppRoutes.profile);
      },
    ),
  );
}
