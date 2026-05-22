import '../../../core/services/local_storage.dart';
import '../../../data/datasource/remote/favorite_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/class/status_request.dart';
import '../../core/functions/handling_data_controller.dart';
import '../../data/datasource/remote/product/product_data.dart';
import '../../core/class/crud.dart';
import 'cart_controller.dart';

class ProductDetailsController extends GetxController {
  ProductData productData = ProductData(Crud());
  CartController cartController = Get.put(CartController());
  FavoriteData favoriteData = FavoriteData(Crud());

  StatusRequest statusRequest = StatusRequest.none;
  Map<String, dynamic> product = {};

  final String favKey = "user_favorites";
  @override
  void onInit() {
    getData();
    super.onInit();
  }

  @override
  void onClose() {
    product = {};
    statusRequest = StatusRequest.none;
    super.onClose();
  }

  void addProductToCart() {
    if (product.isNotEmpty) {
      cartController.addToCart(product);
    }
  }

  Future<void> toggleFavorite() async {
    var response = await favoriteData.toggleData(
      LocalStorage.getUserId().toString(),
      product['id'].toString(),
    );

    statusRequest = handlingData(response);
    if (StatusRequest.success == statusRequest) {
      if (response['status'] == "success") {
        bool isAdded = response['action'] == "added";

        Get.snackbar(
          "favorites".tr,
          isAdded ? "Added to favorites".tr : "Removed from favorites".tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: (isAdded ? Colors.green : Colors.red).withOpacity(
            0.4,
          ),
          colorText: Colors.white,
        );
      }
    } else {
      Get.snackbar("Error".tr, "Connection error".tr);
    }
    update();
  }

  bool isFavorite(List<dynamic> favListFromPrefs) {
    return favListFromPrefs.any((item) => item['id'] == product['id']);
  }

  Future<List<dynamic>> getFavorites() async {
    List favoritesList = [];
    var res = await favoriteData.getData((LocalStorage.getUserId()).toString());
    statusRequest = handlingData(res);
    if (StatusRequest.success == statusRequest) {
      if (res['status'] == "success") {
        favoritesList.addAll(res['data']);
      } else {
        favoritesList.addAll([]);
      }
    }
    return favoritesList;
  }

  getData() async {
    statusRequest = StatusRequest.loading;
    update();

    var argProduct = Get.arguments?["product"];
    if (argProduct == null) {
      statusRequest = StatusRequest.failure;
      update();
      return;
    }

    var response = await productData.getData(argProduct["id"].toString());
    statusRequest = handlingData(response);

    if (StatusRequest.success == statusRequest) {
      if (response['product'] != null) {
        product = Map<String, dynamic>.from(response['product']);
      }
    } else {
      statusRequest = StatusRequest.failure;
    }
    update();
  }
}
