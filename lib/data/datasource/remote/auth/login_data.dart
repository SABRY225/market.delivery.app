import '../../../../data/datasource/remote/linkapi.dart';
import '../../../../../core/class/crud.dart';

class LoginData {
  Crud crud;
  LoginData(this.crud);

  postData(String email) async {
    var response = await crud.postData(AppLink.login, {"email": email});
    return response.fold((l) => l, (r) => r);
  }
}
