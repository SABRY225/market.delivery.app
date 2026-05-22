import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes.dart';
import '../../../controller/auth/signup_controller.dart';
import '../../../core/class/status_request.dart';
class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SignUpController());

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Get.offNamed(AppRoutes.login),
        ),
      ),
      body: GetBuilder<SignUpController>(
        builder: (controller) =>Container(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: ListView(
          children: [
            Image.asset("assets/images/logo.png", width: 150, height: 150),
            Text(
              "create_account".tr,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 28, letterSpacing: 4, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "join_the_world_of_elite_silver".tr,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 50),
            
            _buildTextField(controller: controller.name,hint: "full_name".tr, icon: Icons.person_outline),
            const SizedBox(height: 20),
            _buildTextField(controller: controller.phone,hint: "phone_number".tr, icon: Icons.phone_outlined,maxLength: 9),
            const SizedBox(height: 20),
            _buildTextField(controller: controller.email,hint: "email_address".tr, icon: Icons.email_outlined),
            const SizedBox(height: 20),
            _buildTextField(controller: controller.address,hint: "address".tr, icon: Icons.home_outlined),
            
            const SizedBox(height: 40),
            SizedBox(
              height: 55,
              child: controller.statusRequest == StatusRequest.loading 
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : ElevatedButton(
                onPressed: () => controller.signUp(), 
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                ),
                child: Text("signup".tr, style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
                child: Text("already_have_an_account?_log_in".tr, style: TextStyle(color: Colors.grey)),
              ),
            ),
          ],
        ),
      ),
      )
    );
  }

Widget _buildTextField({
  required TextEditingController controller,
  required String hint,
  required IconData icon,
  int? maxLength,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: TextInputType.phone, 
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.grey),
      
      prefix: hint == "phone_number".tr
          ? const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                "+962 ",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
          : null,

      filled: true,
      fillColor: const Color(0xFF1A1A1A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: BorderSide.none,
      ),
      counterText: maxLength != null ? "char_limit".trParams({"limit": maxLength.toString()}): null, // عرض عدد الأحرف المتبقية
    ),
    maxLength: maxLength, 
  );
}
}