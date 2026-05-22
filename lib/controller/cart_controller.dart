import 'dart:convert';
import '../../../data/datasource/remote/linkapi.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../core/services/local_storage.dart';

class CartController extends GetxController {
  var cartItems = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  int get cartCount => cartItems.length;
  final String apiUrl = AppLink.cart;
  final int? userId = LocalStorage.getUserId();

  @override
  void onInit() {
    super.onInit();
    fetchCartFromServer();
  }

  Future<void> fetchCartFromServer() async {
    isLoading.value = true;
    try {
      final response = await http.get(Uri.parse("$apiUrl/$userId"));
      if (response.statusCode == 200) {
        List decoded = jsonDecode(response.body);
        List<Map<String, dynamic>> secureList = decoded
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        cartItems.assignAll(secureList);
        update();
      }
    } catch (e) {
      Get.log("خطأ في تحميل السلة: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> syncCartWithServer() async {
    try {
      await http.post(
        Uri.parse("$apiUrl/sync"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userId": userId, "items": cartItems.toList()}),
      );
    } catch (e) {
      Get.log("خطأ في مزامنة السلة: $e");
    }
  }

  void clearCart() async {
    cartItems.clear();
    await syncCartWithServer();
  }

  void addToCart(var product) async {
    int index = cartItems.indexWhere((item) => item['id'] == product['id']);
    if (index != -1) {
      cartItems[index]['qty'] += 1;
    } else {
      cartItems.add({...product, 'qty': 1});
    }
    cartItems.refresh();
    update();
    await syncCartWithServer();

    Get.snackbar(
      "cart alert".tr,
      "Product added to cart".tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void increaseQty(int id) async {
    int index = cartItems.indexWhere((item) => item['id'] == id);
    if (index != -1) {
      cartItems[index]['qty'] += 1;
      cartItems.refresh();
      await syncCartWithServer();
    }
  }

  void decreaseQty(int id) async {
    int index = cartItems.indexWhere((item) => item['id'] == id);
    if (index != -1) {
      if (cartItems[index]['qty'] > 1) {
        cartItems[index]['qty'] -= 1;
      } else {
        cartItems.removeAt(index);
      }
      cartItems.refresh();
      update();
      await syncCartWithServer();
    }
  }

  void removeItem(int id) async {
    cartItems.removeWhere((item) => item['id'] == id);
    await syncCartWithServer();
  }

  double get subtotal => cartItems.fold(0.0, (sum, item) {
    double price = double.tryParse(item['price'].toString()) ?? 0.0;
    int qty = int.tryParse(item['qty'].toString()) ?? 1;
    return sum + (price * qty);
  });
  double get total => subtotal;
}
