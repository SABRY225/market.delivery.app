import 'package:delivery/core/services/local_storage.dart';
import '../../../data/datasource/remote/linkapi.dart';
import '../../../core/class/crud.dart';

class HomeData {
  Crud crud;
  HomeData(this.crud);
  var userId = LocalStorage.getUserId();


  getData() async {
    var response = await crud.getData("${AppLink.deliveryStatus}/$userId/myorders-pending");
    return response.fold((l) => l, (r) => r);
  }

  postStatus(online) async {
    var response = await crud.putData("${AppLink.deliveryStatus}/$userId/online",online);
    return response.fold((l) => l, (r) => r);
  }

  postAccept(id) async {
    var response = await crud.postData("${AppLink.deliveryStatus}/$id/accept",{});
    return response.fold((l) => l, (r) => r);
  }
  postReject(id) async {
    var response = await crud.postData("${AppLink.deliveryStatus}/$id/reject",{});
    return response.fold((l) => l, (r) => r);
  }
}
