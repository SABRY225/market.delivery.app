import '../../../core/services/local_storage.dart';
import 'package:flutter/material.dart';
import '../../data/datasource/remote/checkout_view_model.dart';
import '../widget/custom_text_field.dart';
import '../widget/order_summary.dart';
import 'package:get/get.dart';

class CheckoutInvestmentPage extends StatefulWidget {
  const CheckoutInvestmentPage({super.key});

  @override
  State<CheckoutInvestmentPage> createState() => _CheckoutInvestmentPageState();
}

class _CheckoutInvestmentPageState extends State<CheckoutInvestmentPage> {
  final _formKey = GlobalKey<FormState>();
  final _viewModel = CheckoutViewModel();

  final TextEditingController _phone = TextEditingController();
  final TextEditingController _phone2 = TextEditingController();
  final TextEditingController _address = TextEditingController();

  List _cities = [];
  Map? _selectedCity;
  int _quantity = 1;
  bool _loading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() async {
    final data = await _viewModel.fetchCities();
    setState(() {
      _cities = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map args = ModalRoute.of(context)!.settings.arguments as Map;
    final investment = args['investment'];

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title:  Text("checkout investment".tr, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.blueAccent),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Contact Information".tr),
                    CustomCheckoutField(
                      controller: _phone,
                      label: "Primary Phone".tr,
                      prefixText: "+962 ",
                      maxLength: 9,
                      validator: (val) {
                        if (val == null || val.isEmpty)
                          return "Please enter your phone number".tr;
                        if (val.length != 9)
                          return "Phone number must be 9 digits".tr;
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    CustomCheckoutField(
                      controller: _phone2,
                      label: "Secondary Phone".tr,
                      prefixText: "+962 ",
                      maxLength: 9,
                      validator: (val) {
                        if (val == null || val.isEmpty)
                          return "Please enter your phone number".tr;
                        if (val.length != 9)
                          return "Phone number must be 9 digits".tr;
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),
                    _buildLabel("Order Quantity".tr),
                    _buildQuantitySelector(),

                    const SizedBox(height: 20),
                    _buildLabel("Shipping Details".tr),
                    _buildCityDropdown(),
                    const SizedBox(height: 12),
                    CustomCheckoutField(
                      controller: _address,
                      label: "Detailed Address".tr,
                      icon: Icons.location_on,
                    ),

                    const SizedBox(height: 30),
                    OrderSummary(
                      itemPrice: investment['price'],
                      shippingPrice: _selectedCity?['price'] ?? 0,
                      quantity: _quantity,
                    ),

                    const SizedBox(height: 30),
                    _buildSubmitButton(investment),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 5),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Number of items".tr, style: TextStyle(color: Colors.grey)),
          Row(
            children: [
              _qtyBtn(
                Icons.remove,
                () => setState(() => _quantity > 1 ? _quantity-- : null),
              ),
              SizedBox(
                width: 40,
                child: Center(
                  child: Text(
                    "$_quantity",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              _qtyBtn(Icons.add, () => setState(() => _quantity++)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.blueAccent),
      constraints: const BoxConstraints(),
      padding: const EdgeInsets.all(8),
    );
  }

  Widget _buildCityDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<Map>(
        dropdownColor: const Color(0xFF1A1A1A),
        decoration: const InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(Icons.location_city, color: Colors.grey, size: 20),
        ),
        hint: Text("Select City".tr, style: TextStyle(color: Colors.grey)),
        value: _selectedCity,
        items: _cities
            .map(
              (city) => DropdownMenuItem<Map>(
                value: city,
                child: Text(
                  city['name'],
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            )
            .toList(),
        onChanged: (val) => setState(() => _selectedCity = val),
        validator: (val) => val == null ? "Please select a city".tr : null,
      ),
    );
  }

  Widget _buildSubmitButton(Map inv) {
    final userId = LocalStorage.getUserId();
    final name = LocalStorage.getName() ?? "User";
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: _isSubmitting
            ? null
            : () async {
                if (_formKey.currentState!.validate()) {
                  setState(() => _isSubmitting = true);
                  double itemPrice =
                      double.tryParse(inv['price'].toString()) ?? 0.0;
                  double shippingPrice =
                      double.tryParse(
                        _selectedCity?['price']?.toString() ?? "0.0",
                      ) ??
                      0.0;

                  // حساب الإجمالي النهائي
                  double finalTotal = (itemPrice * _quantity) + shippingPrice;
                  bool success = await _viewModel.submitOrder({
                    "userId": userId,
                    "fullName": name,
                    "productPrice": inv['price'],
                    "productName": inv['name'],
                    "quantity": _quantity,
                    "phone": _phone.text,
                    "secondaryPhone": _phone2.text,
                    "cityId": _selectedCity?['id'],
                    "total_price": finalTotal,
                    "address": _address.text,
                    "paymentMethod": "cod",
                  });
                  setState(() => _isSubmitting = false);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Order Placed Successfully!".tr),
                      ),
                    );
                    Navigator.pop(context);
                  }
                }
              },
        child: _isSubmitting
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                "Confirm Order".tr,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
