import 'package:delivery/core/class/crud.dart';
import 'package:delivery/data/datasource/remote/linkapi.dart';

class ShiftsData {
  Crud crud;
  ShiftsData(this.crud);

  Future<Object> getShifts(String deliveryId) async {
    var response = await crud.getData(
      "${AppLink.shifts}/$deliveryId/shifts",
    );
    return response.fold((l) => l, (r) => r);
  }
}
