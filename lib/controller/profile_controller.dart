import '../../../data/datasource/remote/linkapi.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/services/local_storage.dart';

class ProfileController extends GetxController {
  var orderCounter = "0".obs;
  var points = "0".obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
    fetchProfileData();
  }

  void loadInitialData() {
    orderCounter.value = LocalStorage.getOrderCounter() ?? "0";
    points.value = LocalStorage.getPoints() ?? "0";
  }

  Future<void> fetchProfileData() async {
    try {
      isLoading(true);
      final token = LocalStorage.getToken();

      final response = await http.get(
        Uri.parse('${AppLink.OrderAndPointByUser}/${LocalStorage.getUserId()}'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        orderCounter.value = data['order_count'].toString();
        points.value = data['user_points'].toString();

        await LocalStorage.setPointAndOrders(
          points: points.value,
          orderCounter: orderCounter.value,
        );
      }
    } catch (e) {
      Get.snackbar("Error".tr, "Failed to retrieve updated data".tr);
    } finally {
      isLoading(false);
    }
  }
}
