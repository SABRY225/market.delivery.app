import '../../../data/datasource/remote/linkapi.dart';
import '../../../core/class/crud.dart';
import '../../../core/services/local_storage.dart';

class OrderData {
  Crud crud;
  OrderData(this.crud);
  var userId = LocalStorage.getUserId();
  getData() async {
    var response = await crud.getData(
      "${AppLink.getOrders}/${userId}",
    );
    return response.fold((l) => l, (r) => r);
  }
}
