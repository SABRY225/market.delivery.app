import 'package:delivery/controller/home_controller.dart';
import 'package:delivery/controller/settings_controller.dart';
import 'package:delivery/core/class/crud.dart';
import 'package:delivery/core/class/status_request.dart';
import 'package:delivery/core/services/local_storage.dart';
import 'package:delivery/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static Color get primaryColor => const Color(0xFFFF5722);
  static Color get textColor => Get.isDarkMode ? Colors.white : const Color(0xFF0F172A);
  static Color get subtitleColor => Get.isDarkMode ? Colors.white70 : const Color(0xFF64748B);
  static Color get backgroundColor => Get.theme.scaffoldBackgroundColor;
  static Color get cardColor => Get.isDarkMode ? const Color(0xFF1E293B) : Colors.white;
  static Color get shadowColor => Get.isDarkMode ? Colors.transparent : Colors.black.withOpacity(0.1);

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => Crud());
    final HomeController controller = Get.put(HomeController());
    Get.put(SettingsController()); 

    return GetBuilder<SettingsController>(
      builder: (settings) {
        return Scaffold(
          backgroundColor: backgroundColor,
          extendBodyBehindAppBar: true,

      drawer: Drawer(
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(32)),
        ),
        child: Container(
          color: backgroundColor,
          child: GetBuilder<HomeController>(
            builder: (controller) => Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    top: 65,
                    bottom: 35,
                    left: 24,
                    right: 24,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, primaryColor.withBlue(50)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(40),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.25),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.white24,
                          shape: BoxShape.circle,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: 32,
                            backgroundColor: Color(0xFFF8FAFC),
                            child: Icon(
                              Icons.person_rounded,
                              size: 38,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${controller.driverData["name"]}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 19,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            GestureDetector(
                              onTap: controller.hasInternet 
                                  ? () => controller.toggleStatus(!controller.isAvailable)
                                  : null,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white30,
                                    width: 0.5,
                                  ),
                                ),
                                child: controller.hasInternet
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: controller.isAvailable
                                                  ? Colors.greenAccent
                                                  : Colors.orangeAccent,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            controller.isAvailable
                                                ? "Online"
                                                : "Offline",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      )
                                    : const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            "Offline (Connecting)",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          SizedBox(width: 6),
                                          _AnimatedGreenDots(),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "working_mode".tr,
                      style: TextStyle(
                        color: subtitleColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                _buildServiceModeSelector(controller),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                  child: Divider(color: Color(0xFFE2E8F0), thickness: 1),
                ),
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildDrawerItem(
                        Icons.account_circle_outlined,
                        "profile".tr,
                        () => Get.toNamed(AppRoutes.infoDelivery),
                      ),
                      _buildDrawerItem(
                        Icons.account_balance_wallet_outlined,
                        "wallet".tr,
                        () => Get.toNamed(AppRoutes.wallet),
                      ),
                      _buildDrawerItem(
                        Icons.analytics_outlined,
                        "payments".tr,
                        () => Get.toNamed(AppRoutes.statistics),
                      ),
                      _buildDrawerItem(
                        Icons.mail_outline_rounded,
                        "mailbox".tr,
                        () => Get.toNamed(AppRoutes.notification),
                      ),
                      _buildDrawerItem(
                        Icons.calendar_today_outlined,
                        "schedule".tr,
                        () => Get.toNamed(AppRoutes.schedule),
                      ),
                      _buildDrawerItem(
                        Icons.work_history_outlined,
                        "shifts".tr,
                        () => Get.toNamed(AppRoutes.shifts),
                      ),
                      _buildDrawerItem(
                        Icons.local_offer_outlined,
                        "opportunities".tr,
                        () => Get.toNamed(AppRoutes.opportunities),
                      ),
                      _buildDrawerItem(
                        Icons.support_agent,
                        "contact".tr,
                        () => Get.toNamed(AppRoutes.contact),
                      ),
                      _buildDrawerItem(
                        Icons.medical_services_outlined,
                        "ambulance".tr,
                        () async {
                          final Uri phoneUri = Uri(scheme: 'tel', path: '123');
                          if (await canLaunchUrl(phoneUri)) {
                            await launchUrl(phoneUri);
                          } else {
                            Get.snackbar("Error", "Cannot make call from this device");
                          }
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Divider(color: Color(0xFFE2E8F0), thickness: 1),
                      ),
                      _buildDrawerItem(
                        Icons.settings_rounded,
                        "settings".tr,
                        () => Get.toNamed(AppRoutes.settings),
                      ),
                      _buildDrawerItem(
                        Icons.language_rounded,
                        "app_language".tr,
                        () => Get.toNamed(AppRoutes.selectLanguage),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 30,
                  ),
                  child: _buildDrawerItem(
                    Icons.logout_rounded,
                    "logout".tr,
                    () async {
                      LocalStorage.clear();
                      Get.offAllNamed(AppRoutes.login);
                    },
                    isLogout: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: GetBuilder<HomeController>(
          builder: (controller) => _buildMainScreenStatusToggle(controller),
        ),
        actions: [
          Builder(
            builder: (context) => Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 6.0,
              ),
              child: Container(
                width: 45,
                decoration: BoxDecoration(
                  color: cardColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(Icons.menu, color: textColor, size: 24),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
            ),
          ),
        ],
      ),
      body: GetBuilder<HomeController>(
        builder: (controller) {
          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: controller.kInitialCenter,
                  zoom: controller.kInitialZoom,
                ),
                onMapCreated: (GoogleMapController mapController) {
                  controller.mapController = mapController;
                },
                markers: controller.markers,
                polylines: controller.polylines,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
              ),

              Positioned(
                top: kToolbarHeight + 40,
                right: 16,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: shadowColor,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: InkWell(
                        onTap: () => Get.toNamed(AppRoutes.contact),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.headset_mic_outlined,
                            color: primaryColor,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: shadowColor,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: InkWell(
                        onTap: () => controller.goToMyLocation(),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.my_location_rounded,
                            color: primaryColor,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              DraggableScrollableSheet(
                initialChildSize: 0.35,
                minChildSize: 0.15,
                maxChildSize: 0.85,
                builder: (context, scrollController) {
                  return Container(
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, -6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Center(
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 16),
                            width: 50,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        _buildOrdersTripsTabSelector(controller),
                        const SizedBox(height: 16),
                        Expanded(
                          child: _buildApiBodyState(
                            controller,
                            scrollController,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
      },
    );
  }

  Widget _buildOrdersTripsTabSelector(HomeController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildSheetTabButton(
              icon: Icons.moped_rounded,
              label: "orders".tr,
              count: controller.ordersList.length,
              isActive: controller.selectedTab == 0,
              onTap: () => controller.switchTab(0),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildSheetTabButton(
              icon: Icons.local_taxi_rounded,
              label: "my_trips".tr,
              count: controller.myTripsList.length,
              isActive: controller.selectedTab == 1,
              onTap: () => controller.switchTab(1),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildSheetTabButton(
              icon: Icons.travel_explore_rounded,
              label: "nearby_trips".tr,
              count: controller.nearbyTripsList.length,
              isActive: controller.selectedTab == 2,
              onTap: () => controller.switchTab(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSheetTabButton({
    required IconData icon,
    required String label,
    required int count,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: isActive ? primaryColor.withOpacity(0.1) : cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive ? primaryColor : (Get.isDarkMode ? Colors.white12 : const Color(0xFFE2E8F0)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 15,
                  color: isActive ? primaryColor : subtitleColor,
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: isActive ? primaryColor : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "$count",
                    style: TextStyle(
                      color: isActive ? Colors.white : subtitleColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isActive ? primaryColor : textColor,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApiBodyState(
    HomeController controller,
    ScrollController scrollController,
  ) {
    Widget content;

    if (controller.statusRequest == StatusRequest.loading) {
      content = Center(
        child: CircularProgressIndicator(color: primaryColor),
      );
    } else if (controller.statusRequest == StatusRequest.failure) {
      content = SingleChildScrollView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: 300,
          child: _buildEmptyOrdersWidget(tab: controller.selectedTab),
        ),
      );
    } else if (controller.statusRequest == StatusRequest.serverfailure ||
        controller.statusRequest == StatusRequest.offlinefailure) {
      content = SingleChildScrollView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: 300,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.wifi_off_rounded,
                  color: subtitleColor,
                  size: 48,
                ),
                const SizedBox(height: 8),
                Text(
                  "Check your internet connection".tr,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () => controller.getDriverOrders(),
                  child: Text(
                    "Retry".tr,
                    style: TextStyle(color: primaryColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      final List currentList = controller.selectedTab == 0
          ? controller.ordersList
          : (controller.selectedTab == 1
              ? controller.myTripsList
              : controller.nearbyTripsList);

      if (currentList.isEmpty) {
        content = SingleChildScrollView(
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: 300,
            child: _buildEmptyOrdersWidget(tab: controller.selectedTab),
          ),
        );
      } else {
        content = ListView.builder(
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          itemCount: currentList.length,
          itemBuilder: (context, index) {
            if (controller.selectedTab == 0) {
              return _buildOrderCard(currentList[index], controller);
            } else {
              return _buildTripCard(
                currentList[index],
                controller,
                isMyTrip: controller.selectedTab == 1,
              );
            }
          },
        );
      }
    }

    return RefreshIndicator(
      color: primaryColor,
      backgroundColor: cardColor,
      onRefresh: () => controller.getDriverOrders(),
      child: content,
    );
  }

  Widget _buildDrawerItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isLogout = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isLogout ? Colors.red.withOpacity(0.08) : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isLogout ? Colors.redAccent : primaryColor,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isLogout ? Colors.redAccent : textColor,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        trailing: isLogout
            ? null
            : Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Color(0xFF94A3B8),
              ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        onTap: onTap,
        dense: true,
      ),
    );
  }

  Widget _buildServiceModeSelector(HomeController controller) {
    final String currentMode = controller.driverData["working_mode"] ?? "all";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Get.isDarkMode ? Colors.white12 : const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            _buildModeButton(
              label: "all_services".tr,
              icon: Icons.all_inclusive_rounded,
              isActive: currentMode == "all",
              onTap: () {
                controller.updateWorkingMode("all");
              },
            ),
            _buildModeButton(
              label: "delivery_only".tr,
              icon: Icons.moped_rounded,
              isActive: currentMode == "delivery",
              onTap: () {
                controller.updateWorkingMode("delivery");
              },
            ),
            _buildModeButton(
              label: "rides_only".tr,
              icon: Icons.local_taxi_rounded,
              isActive: currentMode == "ride",
              onTap: () {
                controller.updateWorkingMode("ride");
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeButton({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isActive ? primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive ? Colors.white : subtitleColor,
                size: 18,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : textColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(Map order, HomeController controller) {
    double lat =
        double.tryParse((order["latitude"] ?? 27.2579).toString()) ??
            27.2579;
    double lng =
        double.tryParse((order["longitude"] ?? 33.8116).toString()) ??
            33.8116;

    final List items = order["items"] is List ? order["items"] : [];
    final String? vendorName =
        items.isNotEmpty ? items.first["vendorName"]?.toString() : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.moped_rounded,
                      color: primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "${"Request number #".tr} ${order["id"]}",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "${order["total"] ?? 0} ${"egp".tr}",
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Divider(height: 24, color: Color(0xFFF1F5F9), thickness: 1.2),

          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              controller.animateAndSelectCustomer(lat, lng);
              _showNavigationSnackbar(order["id"]);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.person_pin_circle_outlined,
                      size: 20,
                      color: subtitleColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "customer_label".tr,
                          style: TextStyle(
                            color: subtitleColor,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          "${order["customer"] ?? ''}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (order["phone"] != null &&
                            "${order["phone"]}".isNotEmpty)
                          Text(
                            "${order["phone"]}",
                            style: TextStyle(
                              color: subtitleColor,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: Color(0xFFFFF3E0),
                    child: Icon(
                      Icons.near_me_rounded,
                      size: 14,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (vendorName != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.storefront_outlined,
                  size: 16,
                  color: subtitleColor,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    items.length > 1
                        ? "$vendorName (+${items.length - 1})"
                        : vendorName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: subtitleColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 12),
          Row(
            children: [
              if (order["deliveryFee"] != null)
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.local_shipping_outlined,
                        size: 16,
                        color: subtitleColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${order["deliveryFee"]} ${"egp".tr}",
                        style: TextStyle(
                          color: subtitleColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              if (order["payment"] != null)
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.payments_outlined,
                        size: 16,
                        color: subtitleColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${order["payment"]}",
                        style: TextStyle(
                          color: subtitleColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Get.toNamed(
                        AppRoutes.detailesOrder,
                        arguments: order,
                      ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      "order_details".tr,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTripCard(
    Map trip,
    HomeController controller, {
    bool isMyTrip = false,
  }) {
    double pickupLat =
        double.tryParse((trip["pickupLat"] ?? 27.2579).toString()) ??
            27.2579;
    double pickupLng =
        double.tryParse((trip["pickupLng"] ?? 33.8116).toString()) ??
            33.8116;
    double dropoffLat =
        double.tryParse((trip["dropoffLat"] ?? 27.2579).toString()) ??
            27.2579;
    double dropoffLng =
        double.tryParse((trip["dropoffLng"] ?? 33.8116).toString()) ??
            33.8116;

    final String distance =
        "${trip["calculatedDistanceKm"] ?? trip["distanceKm"] ?? '-'} ${"km".tr}";
    final String? status = trip["status"]?.toString();

    return InkWell(
      onTap: () {
        Get.toNamed(AppRoutes.tripDetails, arguments: {"tripId": trip["id"]});
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primaryColor.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.local_taxi_rounded,
                      color: primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "${"ride_request_label".tr} #${trip["id"]}",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  if (isMyTrip && status != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      margin: const EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status.tr,
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "${trip["fareAmount"] ?? 0} ${"egp".tr}",
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Divider(height: 24, color: Color(0xFFF1F5F9), thickness: 1.2),

          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              controller.animateAndSelectCustomer(pickupLat, pickupLng);
              _showNavigationSnackbar(trip["id"]);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.my_location_rounded,
                      size: 20,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "pickup_location".tr,
                          style: TextStyle(
                            color: subtitleColor,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          "${trip["pickupAddress"] ?? '-'}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: Color(0xFFFFF3E0),
                    child: Icon(
                      Icons.near_me_rounded,
                      size: 14,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.only(left: 22, top: 2, bottom: 2),
            child: SizedBox(
              height: 16,
              child: VerticalDivider(
                color: subtitleColor,
                thickness: 1.5,
                width: 1,
              ),
            ),
          ),

          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              controller.animateAndSelectCustomer(dropoffLat, dropoffLng);
              _showNavigationSnackbar(trip["id"], isDestination: true);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.flag_rounded,
                      size: 20,
                      color: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "dropoff_location".tr,
                          style: TextStyle(
                            color: subtitleColor,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          "${trip["dropoffAddress"] ?? '-'}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: Color(0xFFFFF3E0),
                    child: Icon(
                      Icons.near_me_rounded,
                      size: 14,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.route_outlined,
                size: 16,
                color: subtitleColor,
              ),
              const SizedBox(width: 4),
              Text(
                distance,
                style: TextStyle(color: subtitleColor, fontSize: 12),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.payments_outlined,
                size: 16,
                color: subtitleColor,
              ),
              const SizedBox(width: 4),
              Text(
                "${trip["paymentMethod"] ?? '-'}",
                style: TextStyle(color: subtitleColor, fontSize: 12),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (isMyTrip) {
                      String? status = trip["status"];
                      if (status == 'accepted') {
                        controller.arriveTrip(trip["id"].toString());
                      } else if (status == 'driver_arrived') {
                        controller.startTripAction(trip["id"].toString());
                      } else if (status == 'in_progress') {
                        controller.completeTripAction(trip["id"].toString());
                      } else {
                        controller.animateAndSelectCustomer(
                          pickupLat,
                          pickupLng,
                        );
                        _showNavigationSnackbar(trip["id"]);
                      }
                    } else {
                      controller.applyForTrip(trip["id"].toString());
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    isMyTrip 
                      ? (trip["status"] == 'accepted' ? "Check-in (I'm outside)".tr 
                        : (trip["status"] == 'driver_arrived' ? "Start Trip".tr 
                        : (trip["status"] == 'in_progress' ? "End Trip".tr : "start_navigation".tr)))
                      : "accept_ride".tr,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }

  void _showNavigationSnackbar(dynamic orderId, {bool isDestination = false}) {
    Get.rawSnackbar(
      message: isDestination
          ? "${"Live navigation to the destination for order number has been activated.".tr} #$orderId"
          : "${"Live navigation is now enabled for order number".tr} #$orderId",
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.TOP,
      backgroundColor: primaryColor.withOpacity(0.9),
    );
  }

  Widget _buildEmptyOrdersWidget({int tab = 0}) {
    final IconData icon = tab == 0
        ? Icons.moped_rounded
        : (tab == 1 ? Icons.local_taxi_rounded : Icons.travel_explore_rounded);

    final String message = tab == 1
        ? "No accepted trips currently".tr
        : "No requests are currently available".tr;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 54,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: textColor,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainScreenStatusToggle(HomeController controller) {
    return GestureDetector(
      onTap: controller.hasInternet 
          ? () => controller.toggleStatus(!controller.isAvailable)
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: controller.hasInternet
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: controller.isAvailable ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    controller.isAvailable ? "Online" : "Offline",
                    style: TextStyle(
                      color: controller.isAvailable ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Offline (Connecting)",
                    style: TextStyle(color: Color(0xFFFF9800), fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8),
                  _AnimatedGreenDots(),
                ],
              ),
      ),
    );
  }
}

class _AnimatedGreenDots extends StatefulWidget {
  const _AnimatedGreenDots();

  @override
  __AnimatedGreenDotsState createState() => __AnimatedGreenDotsState();
}

class __AnimatedGreenDotsState extends State<_AnimatedGreenDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            double opacity =
                0.3 + 0.7 * ((_controller.value * 5 - index) % 5) / 5.0;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.greenAccent.withOpacity(opacity.clamp(0.0, 1.0)),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}