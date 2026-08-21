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

  List ordersList = [];
  List myTripsList = [];
  List nearbyTripsList = [];

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

  Timer? _refreshTimer;

  @override
  void onInit() {
    homeData = HomeData(Get.find());
    getDriverProfile();
    getDriverOrders();
    startLiveLocationTracking();
    _checkInitialInternet();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      getDriverOrders(isSilent: true);
    });
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
            for (var trip in myTripsList) {
              if (trip["status"] == "in_progress") {
                homeData.trackingTrip(trip["id"].toString(), position.latitude, position.longitude);
              }
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
    String? vehicleType = LocalStorage.getVehicleType();
    print("vehicleType: $vehicleType");
    driverData = {
      "id": driverId ?? 0,
      "name": driverName ?? "Captain",
      "working_mode": workingMode ?? "all",
      "vehicleType": vehicleType ?? "",
    };
    isAvailable = LocalStorage.getOnline() ?? true;
    update();
  }

  Future<void> getDriverOrders({bool isSilent = false}) async {
    if (!isSilent) {
      statusRequest = StatusRequest.loading;
      update();
    }

    dynamic response = await homeData.getDriverOrders(driverData["id"]);
    var reqStatus = handlingData(response);

    if (reqStatus == StatusRequest.success) {
      if (response['workingMode'] != null) {
        driverData["working_mode"] = response['workingMode'];
      }

      final rawData = response['data'];

      ordersList.clear();
      if (rawData is Map) {
        final List orders = rawData['orders'] ?? [];
        ordersList.addAll(orders);
      } else if (rawData is List) {
        ordersList.addAll(rawData);
      }
    }

    dynamic nearbyResponse = await homeData.getNearbyTrips(driverData["vehicleType"]?.toString() ?? "");
    if (handlingData(nearbyResponse) == StatusRequest.success) {
      final data = nearbyResponse['data'];
      if (data is List) {
        nearbyTripsList.clear();
        nearbyTripsList.addAll(data);
      }
    }

    dynamic myTripsResponse = await homeData.getMyTrips();
    if (myTripsResponse['success'] == true) {
      final data = myTripsResponse['data'];
      if (data is List) {
        myTripsList.clear();
        myTripsList.addAll(data);
      }
    }

    if (reqStatus == StatusRequest.success || handlingData(nearbyResponse) == StatusRequest.success || handlingData(myTripsResponse) == StatusRequest.success) {
      if (!isSilent) statusRequest = StatusRequest.success;

      markers.removeWhere((m) => m.markerId.value.startsWith('order_') || m.markerId.value.startsWith('trip_'));

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
    } else {
      if (!isSilent) statusRequest = reqStatus;
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
          message: "Trip accepted successfully",
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        );

        await getDriverOrders();
      } else {
        Get.rawSnackbar(
          message: response['message'] ?? "Sorry, trip no longer available",
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        );
      }
    } else {
      Get.rawSnackbar(
        message: "Error communicating with server",
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      );
    }

    update();
  }

  Future<void> arriveTrip(String tripId) async {
    statusRequest = StatusRequest.loading;
    update();

    dynamic response = await homeData.arriveTrip(tripId);
    statusRequest = handlingData(response);
    if (statusRequest == StatusRequest.success) {
      if (response['success'] == true) {
        Get.rawSnackbar(message: "Arrival recorded successfully", backgroundColor: Colors.green, duration: const Duration(seconds: 2));
        await getDriverOrders();
      } else {
        Get.rawSnackbar(message: response['message'] ?? "Error occurred", backgroundColor: Colors.orange, duration: const Duration(seconds: 2));
      }
    } else {
      Get.rawSnackbar(message: "Error communicating with server", backgroundColor: Colors.red, duration: const Duration(seconds: 2));
    }
    update();
  }

  Future<void> startTripAction(String tripId) async {
    statusRequest = StatusRequest.loading;
    update();

    dynamic response = await homeData.startTrip(tripId);
    statusRequest = handlingData(response);
    if (statusRequest == StatusRequest.success) {
      if (response['success'] == true) {
        Get.rawSnackbar(message: "Trip started successfully", backgroundColor: Colors.green, duration: const Duration(seconds: 2));
        await getDriverOrders();
      } else {
        Get.rawSnackbar(message: response['message'] ?? "Error occurred", backgroundColor: Colors.orange, duration: const Duration(seconds: 2));
      }
    } else {
      Get.rawSnackbar(message: "Error communicating with server", backgroundColor: Colors.red, duration: const Duration(seconds: 2));
    }
    update();
  }

  Future<void> completeTripAction(String tripId) async {
    statusRequest = StatusRequest.loading;
    update();

    dynamic response = await homeData.completeTrip(tripId);
    statusRequest = handlingData(response);
    if (statusRequest == StatusRequest.success) {
      if (response['success'] == true) {
        Get.rawSnackbar(message: "Trip ended successfully", backgroundColor: Colors.green, duration: const Duration(seconds: 2));
        await getDriverOrders();
      } else {
        Get.rawSnackbar(message: response['message'] ?? "Error occurred", backgroundColor: Colors.orange, duration: const Duration(seconds: 2));
      }
    } else {
      Get.rawSnackbar(message: "Error communicating with server", backgroundColor: Colors.red, duration: const Duration(seconds: 2));
    }
    update();
  }

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
    statusRequest = StatusRequest.loading;
    update();
    dynamic response = await homeData.updateWorkingMode(driverData["id"], mode);
    statusRequest = handlingData(response);

    if (statusRequest == StatusRequest.success) {
      driverData["working_mode"] = mode;

      await LocalStorage.setWorkingMode(mode);

      String modeName = mode == "all"
          ? "All Services"
          : (mode == "delivery" ? "Delivery only" : "Rides only");

      Get.rawSnackbar(
        message: "Work mode changed to: $modeName",
        backgroundColor: const Color(0xFFFF5722),
        duration: const Duration(seconds: 2),
      );

      await getDriverOrders();
    } else {
      Get.rawSnackbar(
        message: "Failed to change work mode",
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      );
      update();
    }
  }

  void switchTab(int index) {
    if (selectedTab == index) return;
    selectedTab = index;
    update();
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    positionStream?.cancel();
    mapController?.dispose();
    _connectivitySubscription?.cancel();
    super.onClose();
  }
}