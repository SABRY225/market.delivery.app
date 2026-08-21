import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/auth/login_controller.dart';
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
      backgroundColor: const Color(0xFFF8FAFC), 
      body: GetBuilder<LoginController>(
        builder: (controller) => SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 70, 
                        backgroundImage: AssetImage("assets/images/logo.png"),
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    "welcome_back".tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textColor, 
                      fontSize: 28, 
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),

                  TextFormField(
                    controller: controller.phone, 
                    keyboardType: TextInputType.phone,
                    style: TextStyle(color: textColor, fontSize: 16), 
                    decoration: InputDecoration(
                      hintText: "phone_number".tr,
                      hintStyle: TextStyle(color: iconColor, fontSize: 14),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.phone_android_outlined, color: iconColor),
                            SizedBox(width: 8),

                          ],
                        ),
                      ),
                      filled: true,
                      fillColor: fieldColor,
                      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none, 
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1), 
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: primaryColor, width: 1.5), 
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: controller.password, 
                    obscureText: controller.isPasswordHidden, 
                    style: TextStyle(color: textColor, fontSize: 16), 
                    decoration: InputDecoration(
                      hintText: "password".tr,
                      hintStyle: TextStyle(color: iconColor, fontSize: 14),
                      prefixIcon: Icon(Icons.lock_outline_rounded, color: iconColor),
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.isPasswordHidden 
                              ? Icons.visibility_off_outlined 
                              : Icons.visibility_outlined,
                          color: iconColor,
                        ),
                        onPressed: () {
                          controller.isPasswordHidden = !controller.isPasswordHidden;
                          controller.update(); 
                        },
                      ),
                      filled: true,
                      fillColor: fieldColor,
                      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none, 
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1), 
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: primaryColor, width: 1.5), 
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    height: 56,
                    child: controller.statusRequest == StatusRequest.loading
                        ? Center(
                            child: CircularProgressIndicator(color: primaryColor),
                          )
                        : ElevatedButton(
                            onPressed: () => controller.login(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor, 
                              foregroundColor: Colors.white, 
                              elevation: 2, 
                              shadowColor: primaryColor.withOpacity(0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              "login".tr,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 0.5,
                                color: Colors.white,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}