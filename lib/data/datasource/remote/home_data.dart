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
    // Replace 'crud' with your existing CRUD/Api service instance inside HomeData
    var response = await crud.postData(
      "${AppLink.applytrip}/$tripId", // Adjust URL to match your route setup
      {"driverId": driverId},
    );
    return response.fold((l) => l, (r) => r);
  }
}
