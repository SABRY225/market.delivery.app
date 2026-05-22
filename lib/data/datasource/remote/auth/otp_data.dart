import '../../../../data/datasource/remote/linkapi.dart';
import '../../../../../core/class/crud.dart';

class OTPData {
  Crud crud;
  OTPData(this.crud);

  postData(String email, String otp) async {
    var response = await crud.postData(AppLink.verifyCode, {
      "email": email,
      "code": otp,
    });
    return response.fold((l) => l, (r) => r);
  }
}
