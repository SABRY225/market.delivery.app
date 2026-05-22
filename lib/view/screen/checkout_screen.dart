import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controller/cart_controller.dart';
import '../../controller/checkout_controller.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.find();
    final CheckoutController controller = Get.put(CheckoutController());

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          "checkout".tr,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.orange),
          );
        }
        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("CONTACT INFORMATION".tr),
                  _phoneField("Primary Phone".tr, controller.phoneController),
                  const SizedBox(height: 12),
                  _phoneField(
                    "Secondary Phone (Optional)".tr,
                    controller.phone2Controller,
                  ),

                  const SizedBox(height: 30),
                  _buildSectionTitle("SHIPPING ADDRESS".tr),
                  _buildCityDropdown(controller),
                  const SizedBox(height: 12),
                  _customTextField(
                    "Address Details (Building, Street...)".tr,
                    controller.addressDetailsController,
                    Icons.map,
                    TextInputType.multiline,
                  ),

                  const SizedBox(height: 30),
                  _buildSectionTitle("PAYMENT METHOD".tr),
                  Obx(
                    () => Column(
                      children: [
                        _paymentOption(
                          "Cash on Delivery".tr,
                          controller.selectedPaymentMethod.value == "cash",
                          Icons.money,
                          () => controller.selectedPaymentMethod.value = "cash",
                        ),
                        _paymentOption(
                          "Pay My Points".tr,
                          controller.selectedPaymentMethod.value == "points",
                          Icons.radio_button_checked_sharp,
                          () =>
                              controller.selectedPaymentMethod.value = "points",
                        ),
                        _paymentOption(
                          "Credit Card (Soon)".tr,
                          false,
                          Icons.credit_card,
                          null,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                  _buildOrderSummary(cartController, controller),
                  const SizedBox(height: 100),
                ],
              ),
            ),
            _buildBottomAction(cartController, controller),
          ],
        );
      }),
    );
  }

  Widget _phoneField(String hint, TextEditingController ctr) {
    return TextField(
      controller: ctr,
      keyboardType: TextInputType.phone,
      style: const TextStyle(color: Colors.white),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(9),
      ],
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        prefixIcon: Container(
          width: 80,
          alignment: Alignment.center,
          child: const Text(
            "+962",
            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
          ),
        ),
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.orange),
        ),
      ),
    );
  }

  Widget _buildCityDropdown(CheckoutController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(15),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<dynamic>(
          dropdownColor: const Color(0xFF1A1A1A),
          hint: Text(
            "Select Your City".tr,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          value: controller.selectedCity.isEmpty
              ? null
              : controller.selectedCity.value,
          isExpanded: true,
          icon: const Icon(Icons.expand_more, color: Colors.orange),
          items: controller.cities.map((city) {
            return DropdownMenuItem(
              value: city,
              child: Text(
                "${city['name']} (+${city['price']} )" + "egp".tr,
                style: const TextStyle(color: Colors.white),
              ),
            );
          }).toList(),
          onChanged: (val) => controller.selectedCity.value = val,
        ),
      ),
    );
  }

  Widget _buildOrderSummary(CartController cart, CheckoutController checkout) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          _summaryRow(
            "Subtotal".tr,
            "${cart.total.toStringAsFixed(2)} " + "egp".tr,
          ),
          _summaryRow(
            "Shipping Fee".tr,
            "${checkout.shippingCost.toStringAsFixed(2)} " + "egp".tr,
          ),
          const Divider(color: Colors.white10, height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "total".tr,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "${(cart.total + checkout.shippingCost).toStringAsFixed(2)} " +
                    "egp".tr,
                style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction(
    CartController cart,
    CheckoutController controller,
  ) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withOpacity(0), Colors.black],
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.all(18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            onPressed: controller.isSubmitting.value
                ? null
                : () => _validateAndSubmit(cart, controller),
            child: controller.isSubmitting.value
                ? const CircularProgressIndicator(color: Colors.black)
                : Text(
                    "CONFIRM ORDER".tr,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  void _validateAndSubmit(CartController cart, CheckoutController controller) {
    if (controller.phoneController.text.length < 9) {
      Get.snackbar(
        "Required".tr,
        "Please enter a valid phone number".tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } else if (controller.selectedCity.isEmpty) {
      Get.snackbar(
        "Required".tr,
        "Please select a shipping city".tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } else if (controller.addressDetailsController.text.isEmpty) {
      Get.snackbar(
        "Required".tr,
        "Please enter your address details".tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } else {
      controller.placeOrder(cart);
    }
  }

  Widget _buildSectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      title,
      style: const TextStyle(
        color: Colors.grey,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.1,
      ),
    ),
  );

  Widget _customTextField(
    String hint,
    TextEditingController ctr,
    IconData icon,
    TextInputType type,
  ) => TextField(
    controller: ctr,
    keyboardType: type,
    style: const TextStyle(color: Colors.white),
    maxLines: type == TextInputType.multiline ? 3 : 1,
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.orange, size: 20),
      filled: true,
      fillColor: const Color(0xFF1A1A1A),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.orange),
      ),
    ),
  );

  Widget _summaryRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(color: Colors.white)),
      ],
    ),
  );

  Widget _paymentOption(
    String title,
    bool active,
    IconData icon,
    VoidCallback? onTap,
  ) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: active ? Colors.orange : Colors.transparent),
      ),
      child: Row(
        children: [
          Icon(icon, color: active ? Colors.orange : Colors.grey),
          const SizedBox(width: 15),
          Text(
            title,
            style: TextStyle(color: active ? Colors.white : Colors.grey),
          ),
          const Spacer(),
          if (active)
            const Icon(Icons.check_circle, color: Colors.orange, size: 20),
        ],
      ),
    ),
  );
}
