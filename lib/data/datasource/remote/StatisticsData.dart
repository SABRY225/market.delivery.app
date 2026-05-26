
import 'package:delivery/core/class/crud.dart';
import 'package:delivery/core/services/local_storage.dart';
import 'package:delivery/data/datasource/remote/linkapi.dart';

class StatisticsData {
  final Crud crud;

  StatisticsData(this.crud);
 var userId = LocalStorage.getUserId();
  getStats() async {
    var response = await crud.getData("${AppLink.statistics}+$userId/myorders-history");
    return response.fold((l) => l, (r) => r);
  }
}
