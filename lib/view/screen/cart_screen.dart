import '../../../data/datasource/remote/linkapi.dart';
import '../../../routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/cart_controller.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CartController controller = Get.put(CartController());

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("cart".tr, style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.cartItems.isEmpty) {
          return Center(
            child: Text(
              "The basket is empty".tr,
              style: TextStyle(color: Colors.grey),
            ),
          );
        }
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: controller.cartItems.length,
                padding: const EdgeInsets.all(15),
                itemBuilder: (context, index) {
                  var item = controller.cartItems[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        // صورة المنتج
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            '${AppLink.imagesStatic}/${item['image']}',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "${item['price']} " + "egp".tr,
                                style: const TextStyle(color: Colors.orange),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Row(
                              children: [
                                _qtyBtn(
                                  Icons.remove,
                                  () => controller.decreaseQty(item['id']),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  child: Text(
                                    "${item['qty']}",
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                _qtyBtn(
                                  Icons.add,
                                  () => controller.increaseQty(item['id']),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                                size: 20,
                              ),
                              onPressed: () =>
                                  controller.removeItem(item['id']),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            _buildSummary(controller),
          ],
        );
      }),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white24),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }

  Widget _buildSummary(CartController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          _rowSummary(
            "total".tr,
            "${controller.total.toStringAsFixed(2)} " + "egp".tr,
            isTotal: true,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.all(15),
              ),
              onPressed: () {
                Get.toNamed(AppRoutes.checkout);
              },
              child: Text(
                "checkout".tr,
                style: TextStyle(
                  color: const Color.fromARGB(255, 255, 254, 254),
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rowSummary(String title, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isTotal ? Colors.white : Colors.grey,
              fontSize: isTotal ? 18 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isTotal ? Colors.orange : Colors.white,
              fontSize: isTotal ? 20 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
