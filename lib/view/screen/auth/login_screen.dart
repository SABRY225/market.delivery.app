import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/auth/login_controller.dart';
import '../../../routes.dart';
import '../../../core/class/status_request.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static const Color primaryColor = Color(0xFFFF5722); 
  static const Color textColor = Color(0xFF1E293B);   
  static const Color iconColor = Color(0xFF64748B);    
  static const Color fieldColor = Colors.white;        

  @override
  Widget build(BuildContext context) {
    Get.put(LoginController());

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 238, 236, 236), 
      body: GetBuilder<LoginController>(
        builder: (controller) => Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
          child: ListView(
            children: [
              const SizedBox(height: 80),
              const CircleAvatar(
                radius: 120, 
                backgroundImage: AssetImage("assets/images/logo.png"),
                backgroundColor: Colors.transparent,
              ),
              const SizedBox(height: 20),
              Text(
                "welcome_back".tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: textColor, 
                  fontSize: 26, 
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),

              _buildTextField(
                controller: controller.email,
                hint: "email_address".tr,
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 20),

              SizedBox(
                height: 55,
                child: controller.statusRequest == StatusRequest.loading
                    ? const Center(
                        child: CircularProgressIndicator(color: primaryColor),
                      )
                    : ElevatedButton(
                        onPressed: () => controller.login(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor, 
                          foregroundColor: Colors.white, 
                          elevation: 1, 
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          "login".tr,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 1,
                            color: Colors.white,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: textColor), 
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: iconColor, fontSize: 14),
        prefixIcon: Icon(icon, color: iconColor),
        filled: true,
        fillColor: fieldColor,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none, 
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1), 
        ),
      ),
    );
  }
}
