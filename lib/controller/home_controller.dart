import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:delivery/core/services/local_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:delivery/core/functions/handling_data_controller.dart';
import 'package:delivery/data/datasource/remote/home_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/class/status_request.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class HomeController extends GetxController {
  StatusRequest statusRequest = StatusRequest.none;
  bool isAvailable = true;
  bool hasInternet = true;
  StreamSubscription? _connectivitySubscription;

  // 👇 القوائم بقت 3 بدل 2، مطابقة لرد السيرفر الجديد:
  // data.orders / data.myTrips (رحلات مقبولة بالفعل) / data.nearbyTrips (رحلات متاحة للقبول)
  List ordersList = [];
  List myTripsList = [];
  List nearbyTripsList = [];

  // 👇 التبويب الفعّال حالياً في اللوحة السفلية: 0 = طلبات، 1 = رحلاتي، 2 = رحلات قريبة
  int selectedTab = 0;

  Map driverData = {};

  late HomeData homeData;

  GoogleMapController? mapController;
  final LatLng kInitialCenter = const LatLng(27.2579, 33.8116);
  final double kInitialZoom = 13.0;

  LatLng myCurrentLocation = const LatLng(27.2579, 33.8116);

  LatLng? currentSelectedCustomerLocation;

  StreamSubscription<Position>? positionStream;

  Set<Marker> markers = {};
  Set<Polyline> polylines = {};

  @override
  void onInit() {
    homeData = HomeData(Get.find());
    getDriverProfile();
    getDriverOrders();
    startLiveLocationTracking();
    _checkInitialInternet();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
    super.onInit();
  }

  Future<void> _checkInitialInternet() async {
    var result = await Connectivity().checkConnectivity();
    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    bool hasConnection = results.any((result) => 
        result == ConnectivityResult.mobile || 
        result == ConnectivityResult.wifi || 
        result == ConnectivityResult.ethernet);
    
    if (hasInternet != hasConnection) {
      hasInternet = hasConnection;
      update();
    }
  }

  Future<void> startLiveLocationTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 2,
    );

    positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position position) {
            myCurrentLocation = LatLng(position.latitude, position.longitude);
            updateDriverMarkerOnMap();
            if (currentSelectedCustomerLocation != null) {
              drawRoute();
            }
            update();
          },
        );
  }

  void animateAndSelectCustomer(double customerLat, double customerLng) {
    currentSelectedCustomerLocation = LatLng(customerLat, customerLng);
    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(currentSelectedCustomerLocation!, 15.5),
    );
    drawRoute();
  }

  void goToMyLocation() {
    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(myCurrentLocation, 15.5),
    );
  }

Future<void> drawRoute() async {
  if (currentSelectedCustomerLocation == null) return;

  final LatLng start = myCurrentLocation;
  final LatLng end = currentSelectedCustomerLocation!;

  try {
    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/'
      '${start.longitude},${start.latitude};'
      '${end.longitude},${end.latitude}'
      '?overview=full&geometries=geojson',
    );

    final response = await http.get(url).timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final routes = data['routes'];

      if (routes != null && routes.isNotEmpty) {
        final List coords = routes[0]['geometry']['coordinates'];
        final List<LatLng> routePoints =
            coords.map<LatLng>((c) => LatLng(c[1], c[0])).toList();

        polylines
          ..clear()
          ..add(
            Polyline(
              polylineId: const PolylineId("route"),
              points: routePoints,
              width: 5,
              color: const Color(0xFFFF5722),
            ),
          );
        update();
        return;
      }
    }
  } catch (e) {
    print("route error: $e");
  }

  // fallback لو فشل الاتصال بسيرفر التوجيه: نرجع لخط مستقيم مؤقت
  polylines
    ..clear()
    ..add(
      Polyline(
        polylineId: const PolylineId("route_fallback"),
        points: [start, end],
        width: 5,
        color: const Color(0xFFFF5722),
      ),
    );
  update();
}

  void updateDriverMarkerOnMap() {
    markers.removeWhere((m) => m.markerId == const MarkerId("driver_marker"));
    markers.add(
      Marker(
        markerId: const MarkerId("driver_marker"),
        position: myCurrentLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );
  }

  void getDriverProfile() {
    String? driverName = LocalStorage.getName();
    int? driverId = LocalStorage.getUserId();
    String? workingMode = LocalStorage.getWorkingMode();
    driverData = {
      "id": driverId ?? 0,
      "name": driverName ?? "Captain",
      "working_mode": workingMode ?? "all",
    };
    isAvailable = LocalStorage.getOnline() ?? true;
    update();
  }

  // 👇 معدّلة بالكامل عشان تتوافق مع رد getDeliveryOrders الجديد:
  // { workingMode, ordersCount, myTripsCount, nearbyTripsCount,
  //   data: { orders: [...], myTrips: [...], nearbyTrips: [...] } }
  Future<void> getDriverOrders() async {
    ordersList.clear();
    myTripsList.clear();
    nearbyTripsList.clear();
    markers.clear();
    polylines.clear();
    statusRequest = StatusRequest.loading;
    update();

    dynamic response = await homeData.getDriverOrders(driverData["id"]);
    statusRequest = handlingData(response);
    print("response: $response");

    if (statusRequest == StatusRequest.success) {
      // 1. تحديث workingMode إذا جاء في الرد
      if (response['workingMode'] != null) {
        driverData["working_mode"] = response['workingMode'];
      }

      final rawData = response['data'];

      // 2. التحقق من شكل data (سواء كانت Map بها orders/myTrips/nearbyTrips أو List مباشرة)
      if (rawData is Map) {
        final List orders = rawData['orders'] ?? [];
        final List myTrips = rawData['myTrips'] ?? [];
        final List nearbyTrips = rawData['nearbyTrips'] ?? [];
        ordersList.addAll(orders);
        myTripsList.addAll(myTrips);
        nearbyTripsList.addAll(nearbyTrips);
      } else if (rawData is List) {
        // إذا كان السيرفر برجع المصفوفة مباشرة في data
        ordersList.addAll(rawData);
      }

      // 3. إضافة ماركرات طلبات الدليفري
      for (var order in ordersList) {
        if (order["latitude"] != null && order["longitude"] != null) {
          addOrderMarker(
            double.parse(order["latitude"].toString()),
            double.parse(order["longitude"].toString()),
            order["id"].toString(),
            isRide: false,
          );
        }
      }

      // 4. إضافة ماركرات رحلاتي المقبولة (myTrips)
      for (var trip in myTripsList) {
        if (trip["pickupLat"] != null && trip["pickupLng"] != null) {
          addOrderMarker(
            double.parse(trip["pickupLat"].toString()),
            double.parse(trip["pickupLng"].toString()),
            trip["id"].toString(),
            isRide: true,
          );
        }
      }

      // 5. إضافة ماركرات الرحلات القريبة المتاحة للقبول (nearbyTrips)
      for (var trip in nearbyTripsList) {
        if (trip["pickupLat"] != null && trip["pickupLng"] != null) {
          addOrderMarker(
            double.parse(trip["pickupLat"].toString()),
            double.parse(trip["pickupLng"].toString()),
            trip["id"].toString(),
            isRide: true,
          );
        }
      }

      updateDriverMarkerOnMap();
    }

    update();
  }

  void toggleStatus(bool value) {
    isAvailable = value;
    update();
  }

  Future<void> applyForTrip(String tripId) async {
    statusRequest = StatusRequest.loading;
    update();

    dynamic response = await homeData.applyForTrip(tripId, driverData["id"]);
    statusRequest = handlingData(response);
    print(response);
    if (statusRequest == StatusRequest.success) {
      if (response['status'] == 'success') {
        Get.rawSnackbar(
          message: "تم قبول الرحلة بنجاح",
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        );

        // Refresh driver orders and trips lists after successful application
        // (the trip should move from nearbyTrips to myTrips on the server)
        await getDriverOrders();
      } else {
        Get.rawSnackbar(
          message: response['message'] ?? "عذراً، الرحلة لم تعد متاحة",
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        );
      }
    } else {
      Get.rawSnackbar(
        message: "حدث خطأ أثناء التواصل مع السيرفر",
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      );
    }

    update();
  }

  // 👇 بقت تفرّق بين ماركر طلب دليفري وماركر رحلة ركاب بالأيقونة والمفتاح
  void addOrderMarker(
    double lat,
    double lng,
    String orderId, {
    bool isRide = false,
  }) {
    markers.add(
      Marker(
        markerId: MarkerId("${isRide ? 'trip' : 'order'}_$orderId"),
        position: LatLng(lat, lng),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          isRide ? BitmapDescriptor.hueOrange : BitmapDescriptor.hueRed,
        ),
        onTap: () => animateAndSelectCustomer(lat, lng),
      ),
    );
  }

  Future<void> updateWorkingMode(String mode) async {
    // 1. إظهار مؤشر التحميل
    statusRequest = StatusRequest.loading;
    update();
    // 2. إرسال طلب التحديث للسيرفر
    dynamic response = await homeData.updateWorkingMode(driverData["id"], mode);
    statusRequest = handlingData(response);

    if (statusRequest == StatusRequest.success) {
      // 3. التحديث في الذاكرة الحية للكونترولر
      driverData["working_mode"] = mode;

      // 4. الحفظ محلياً في SharedPreferences عبر LocalStorage
      await LocalStorage.setWorkingMode(mode);

      String modeName = mode == "all"
          ? "جميع الخدمات"
          : (mode == "delivery" ? "خدمات التوصيل فقط" : "خدمات الركوب فقط");

      Get.rawSnackbar(
        message: "تم تغيير نمط العمل إلى: $modeName",
        backgroundColor: const Color(0xFFFF5722),
        duration: const Duration(seconds: 2),
      );

      // 5. إعادة جلب الطلبات/الرحلات للتوافق مع المود الجديد
      await getDriverOrders();
    } else {
      Get.rawSnackbar(
        message: "فشل في تغيير نمط العمل، يرجى المحاولة لاحقاً",
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      );
      update();
    }
  }

  // 👇 تبديل التبويب النشط في اللوحة السفلية (طلبات / رحلاتي / رحلات قريبة)
  void switchTab(int index) {
    if (selectedTab == index) return;
    selectedTab = index;
    update();
  }

  @override
  void onClose() {
    positionStream?.cancel();
    mapController?.dispose();
    _connectivitySubscription?.cancel();
    super.onClose();
  }
}