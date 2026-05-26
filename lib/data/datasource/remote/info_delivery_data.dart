
import 'package:delivery/core/class/crud.dart';
import 'package:delivery/core/services/local_storage.dart';
import 'package:delivery/data/datasource/remote/linkapi.dart';

class InfoDeliveryData {
  final Crud crud;

  InfoDeliveryData(this.crud);
 var userId = LocalStorage.getUserId();

  getProfile() async {
    var response = await crud.postData("${AppLink.infoDelivery}/$userId", {});
    return response.fold((l) => l, (r) => r);
  }
}
