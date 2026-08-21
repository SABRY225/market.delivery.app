import '../../../../data/datasource/remote/linkapi.dart';
import '../../../../../core/class/crud.dart';

class LoginData {
  Crud crud;
  LoginData(this.crud);

  Future<Object> postData(String phone, String password, String? fcmToken) async {
    print(AppLink.login);
    var response = await crud.postData(AppLink.login, {
      "phone": phone,
      "password": password,
      "fcmToken": fcmToken,
    });
    return response.fold((l) => l, (r) => r);
  }

  Future<Object> patchData(int deliveryId, String fcmToken) async {
    var response = await crud.patchData(AppLink.updateFcmToken, {
      "deliveryId": deliveryId,
      "fcmToken": fcmToken,
    });
    return response.fold((l) => l, (r) => r);
  }
}