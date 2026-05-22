import '../../../../data/datasource/remote/linkapi.dart';
import '../../../../core/class/crud.dart';

class ProductData {
  Crud crud;
  ProductData(this.crud);
  getData(var productId) async {
    var response = await crud.getData("${AppLink.getProducts}/${productId}");
    return response.fold((l) => l, (r) => r);
  }
}
