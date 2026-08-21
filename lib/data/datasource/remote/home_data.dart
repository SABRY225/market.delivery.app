import '../../../data/datasource/remote/linkapi.dart';
import '../../../core/class/crud.dart';

class HomeData {
  Crud crud;
  HomeData(this.crud);

  Future<Object> getDriverOrders(int driverId) async {
    print("${AppLink.deliveryStatus}/$driverId/myorders-active");
    var response = await crud.getData(
      "${AppLink.deliveryStatus}/$driverId/myorders-active",
    );
    return response.fold((l) => l, (r) => r);
  }

  Future<Object> getNearbyTrips(String vehicleType) async {
    print("${AppLink.nearbyTrips}?vehicleType=$vehicleType");
    var response = await crud.getData(
      "${AppLink.nearbyTrips}?vehicleType=$vehicleType",
    );
    return response.fold((l) => l, (r) => r);
  }

  Future<Object> getMyTrips() async {
    print(AppLink.myTrips);
    var response = await crud.getData(
      AppLink.myTrips,
    );
    return response.fold((l) => l, (r) => r);
  }

  Future<Object> updateDriverStatus(driverId, online) async {
    var response = await crud.putData(
      "${AppLink.deliveryStatus}/$driverId/online",
      online,
    );
    return response.fold((l) => l, (r) => r);
  }

  Future<Object> updateWorkingMode(int driverId, model) async {
    print('${AppLink.workingmode}/$driverId/working-mode');
    var response = await crud.postData(
      "${AppLink.workingmode}/$driverId/working-mode",
      {"model": model},
    );
    return response.fold((l) => l, (r) => r);
  }

  Future<Object> applyForTrip(String tripId, dynamic driverId) async {
    print('${AppLink.applytrip}/$tripId');
    var response = await crud.postData(
      "${AppLink.applytrip}/$tripId", 
      {"driverId": driverId},
    );
    return response.fold((l) => l, (r) => r);
  }

  Future<Object> getTripDetails(String tripId) async {
    print('${AppLink.tripBase}/$tripId');
    var response = await crud.getData(
      "${AppLink.tripBase}/$tripId",
    );
    return response.fold((l) => l, (r) => r);
  }

  Future<Object> arriveTrip(String tripId) async {
    print('${AppLink.tripBase}/$tripId/arrive');
    var response = await crud.patchData(
      "${AppLink.tripBase}/$tripId/arrive",
      {},
    );
    return response.fold((l) => l, (r) => r);
  }

  Future<Object> startTrip(String tripId) async {
    print('${AppLink.tripBase}/$tripId/start');
    var response = await crud.patchData(
      "${AppLink.tripBase}/$tripId/start",
      {},
    );
    return response.fold((l) => l, (r) => r);
  }

  Future<Object> completeTrip(String tripId) async {
    print('${AppLink.tripBase}/$tripId/complete');
    var response = await crud.patchData(
      "${AppLink.tripBase}/$tripId/complete",
      {},
    );
    return response.fold((l) => l, (r) => r);
  }

  Future<Object> trackingTrip(String tripId, double lat, double lng) async {
    var response = await crud.postData(
      "${AppLink.tripBase}/$tripId/tracking",
      {"lat": lat, "lng": lng},
    );
    return response.fold((l) => l, (r) => r);
  }
}