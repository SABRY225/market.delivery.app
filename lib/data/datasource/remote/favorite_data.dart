import '../../../core/class/crud.dart';
import '../../../data/datasource/remote/linkapi.dart';

class FavoriteData {
  Crud crud;
  FavoriteData(this.crud);

  toggleData(String userId, String productId) async {
    var response = await crud.postData(AppLink.favoriteToggle, {
      "userId": userId,
      "productId": productId,
    });
    return response.fold((l) => l, (r) => r);
  }

  getData(String userId) async {
    var response = await crud.getData('${AppLink.favoriteView}/${userId}');
    return response.fold((l) => l, (r) => r);
  }

  removeData(String favId) async {
    var response = await crud.deleteData('${AppLink.favoriteRemove}/${favId}');
    return response.fold((l) => l, (r) => r);
  }
}
