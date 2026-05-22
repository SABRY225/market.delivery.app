import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/auth/otp_controller.dart';
import '../../../core/class/status_request.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OtpController());

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: GetBuilder<OtpController>(
        builder: (_) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              Image.asset("assets/images/logo.png", width: 150, height: 150),
              const SizedBox(height: 20),
              Text(
                "verification".tr,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  letterSpacing: 5,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                "Please enter the code sent to your email".tr,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 50),

              Directionality(
                textDirection:
                    TextDirection.ltr,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    4,
                    (index) =>
                        _buildOtpBox(context, controller.otpControllers[index]),
                  ),
                ),
              ),

              const SizedBox(height: 50),

              SizedBox(
                height: 55,
                child: controller.statusRequest == StatusRequest.loading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : ElevatedButton(
                        onPressed: () => controller.otp(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: Text(
                          "VERIFY and CONTINUE".tr,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
              ),

              const SizedBox(height: 30),

              // TextButton(
              //   onPressed: () {},
              //   child: const Text(
              //     "Resend Code",
              //     style: TextStyle(
              //       color: Colors.grey,
              //       decoration: TextDecoration.underline,
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔥 OTP BOX
  Widget _buildOtpBox(BuildContext context, TextEditingController controller) {
    return SizedBox(
      width: 60,
      height: 70,
      child: TextFormField(
        controller: controller,
        onChanged: (value) {
          if (value.length == 1) {
            FocusScope.of(context).nextFocus();
          } else if (value.isEmpty) {
            FocusScope.of(context).previousFocus();
          }
        },
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          counterText: "",
          filled: true,
          fillColor: const Color(0xFF1A1A1A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
