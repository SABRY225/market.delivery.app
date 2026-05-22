import '../../../data/datasource/remote/linkapi.dart';
import '../../../core/class/crud.dart';

class HomeData {
  Crud crud;
  HomeData(this.crud);

  getData() async {
    var response = await crud.getData("${AppLink.getHome}");
    return response.fold((l) => l, (r) => r);
  }
}
