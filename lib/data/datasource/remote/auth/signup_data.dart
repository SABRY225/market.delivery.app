import '../../../../data/datasource/remote/linkapi.dart';
import '../../../../../core/class/crud.dart';

class SignUpData {
  Crud crud;
  SignUpData(this.crud);

  postData(String name, String email, String phone, String address) async {
    var response = await crud.postData(AppLink.signUp, {
      "name": name,
      "email": email,
      "phone": "+962$phone",
      "address": address,
    });
    return response.fold((l) => l, (r) => r);
  }
}
