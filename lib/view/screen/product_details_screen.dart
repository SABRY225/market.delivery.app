import '../../../controller/cart_controller.dart';
import '../../../controller/product_details_controller.dart';
import '../../../data/datasource/remote/linkapi.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/class/status_request.dart';
import 'dart:convert';

class ProductDetails extends StatelessWidget {
  const ProductDetails({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ProductDetailsController());
    Get.put(CartController());
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      bottomNavigationBar: _buildBottomAction(context),

      body: GetBuilder<ProductDetailsController>(
        init: ProductDetailsController(),
        assignId: true,
        builder: (controller) {
          if (controller.statusRequest == StatusRequest.loading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            );
          } else if (controller.statusRequest == StatusRequest.offlinefailure) {
            return _buildError("no_internet_connection".tr);
          } else if (controller.statusRequest == StatusRequest.serverfailure) {
            return _buildError("server_error".tr);
          } else if (controller.product.isEmpty) {
            return _buildError("Product not available".tr);
          } else {
            var product = controller.product;
            String baseUrl = AppLink.imagesStatic;
            List images = jsonDecode(product['galleryImages']);

            return Scaffold(
              backgroundColor: Colors.transparent,
              body: Stack(
                children: [
                  CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        expandedHeight: 400,
                        pinned: true,
                        backgroundColor: Colors.black,
                        flexibleSpace: FlexibleSpaceBar(
                          background: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                '${baseUrl}/' + product['image'],
                                fit: BoxFit.cover,
                              ),
                              const DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Color(0xFF121212),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      product['name'],
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "egp".tr + " ${product['price']}",
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),

                              Text(
                                "Description".tr,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                product['description'] ??
                                    "No description available.".tr,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 25),

                              if (images.isNotEmpty) ...[
                                Text(
                                  "Gallery".tr,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  height: 80,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: images.length,
                                    itemBuilder: (context, index) => Container(
                                      margin: const EdgeInsets.only(right: 12),
                                      width: 80,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(
                                          color: Colors.white24,
                                        ),
                                        image: DecorationImage(
                                          image: NetworkImage(
                                            '${baseUrl} /' + images[index],
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 25),
                              ],

                              Text(
                                "Specifications".tr,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 15),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                alignment: WrapAlignment.start,
                                children: [
                                  _buildSpecChip(
                                    "SKU".tr,
                                    product['sku'],
                                    Icons.qr_code_2_rounded,
                                  ),
                                  _buildSpecChip(
                                    "Stock".tr,
                                    product['stock'].toString(),
                                    Icons.inventory_2_outlined,
                                  ),
                                  _buildSpecChip(
                                    "Silver Type".tr,
                                    product['silverType'] ?? "N/A",
                                    Icons.type_specimen_sharp,
                                  ),
                                  _buildSpecChip(
                                    "Stone".tr,
                                    product['stoneType'],
                                    Icons.diamond_outlined,
                                  ),
                                  _buildSpecChip(
                                    "Weight".tr,
                                    product['weight']?.toString() ?? "N/A",
                                    Icons.monitor_weight_outlined,
                                  ),
                                  _buildSpecChip(
                                    "Price per Gram".tr,
                                    product['pricePerGram']?.toString() ??
                                        "N/A",
                                    Icons.attach_money_outlined,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 50),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 10,
                    left: 20,
                    child: InkWell(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white10),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildSpecChip(String label, String value, IconData icon) {
    return Container(
      width: Get.width * 0.28,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.orange, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context) {
    ProductDetailsController controller = Get.find();
    CartController controllerCart = Get.find();

    if (!Get.isRegistered<CartController>()) {
      Get.put(CartController());
    }
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          FutureBuilder<List<dynamic>>(
            future: controller.getFavorites(),
            builder: (context, snapshot) {
              bool fav = false;
              if (snapshot.hasData) {
                fav = controller.isFavorite(snapshot.data!);
              }
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: IconButton(
                  icon: Icon(
                    fav ? Icons.favorite : Icons.favorite_border,
                    color: Colors.redAccent,
                  ),
                  onPressed: () async {
                    await controller.toggleFavorite();
                    (context as Element).markNeedsBuild();
                  },
                ),
              );
            },
          ),
          const SizedBox(width: 15),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: const Color.fromARGB(255, 237, 237, 237),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
              onPressed: () {
                controllerCart.addToCart(controller.product);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined),
                  SizedBox(width: 10),
                  Text(
                    "Add to Cart".tr,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String msg) {
    return Center(
      child: Text(msg, style: const TextStyle(color: Colors.white)),
    );
  }
}
