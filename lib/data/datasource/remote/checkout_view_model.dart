import 'dart:convert';
import '../../../data/datasource/remote/linkapi.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

class CheckoutViewModel {
  Future<List> fetchCities() async {
    try {
      final response = await http.get(Uri.parse(AppLink.hippingCities));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      Get.snackbar("Error".tr, "Failed to retrieve updated data".tr);
    }
    return [];
  }

  Future<bool> submitOrder(Map<String, dynamic> orderData) async {
    try {
      final response = await http.post(
        Uri.parse(AppLink.orderSilver),
        headers: {"Content-Type": "application/json"},
        body: json.encode(orderData),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
