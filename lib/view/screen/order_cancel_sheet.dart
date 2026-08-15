import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class OrderCancelSheet extends StatefulWidget {
  final Map order;
  const OrderCancelSheet({super.key, required this.order});

  @override
  State<OrderCancelSheet> createState() => _OrderCancelSheetState();
}

class _OrderCancelSheetState extends State<OrderCancelSheet> {
  static const Color primaryColor = Color(0xFFFF5722);
  static Color get textColor => Get.isDarkMode ? Colors.white : const Color(0xFF0F172A);
  static Color get subtitleColor => Get.isDarkMode ? Colors.white70 : const Color(0xFF64748B);
  static Color get cardColor => Get.isDarkMode ? const Color(0xFF1E293B) : Colors.white;
  static Color get inputColor => Get.isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

  final TextEditingController _reasonController = TextEditingController();
  File? _productImage;
  bool _isSubmitting = false;

  final ImagePicker _picker = ImagePicker();

  bool get _isValid =>
      _reasonController.text.trim().isNotEmpty && _productImage != null;

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
      maxWidth: 1280,
    );
    if (picked != null) {
      setState(() => _productImage = File(picked.path));
    }
  }

  Future<void> _submit() async {
    if (!_isValid) return;
    setState(() => _isSubmitting = true);

    // TODO: استبدل هذا بالنداء الفعلي:
    // await Get.find<HomeController>().cancelOrder(
    //   widget.order["id"].toString(),
    //   _reasonController.text.trim(),
    //   _productImage!,
    // );

    await Future.delayed(const Duration(seconds: 1)); // محاكاة الإرسال

    setState(() => _isSubmitting = false);

    Get.back(); // اغلاق الشيت
    Get.back(); // رجوع من شاشة التفاصيل
    Get.rawSnackbar(
      message: "تم إلغاء الطلب بنجاح".tr,
      backgroundColor: Colors.redAccent,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 45,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Text(
              "إلغاء الطلب #${widget.order["id"]}".tr,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "يرجى كتابة سبب الإلغاء وإرفاق صورة للمنتج".tr,
              style: TextStyle(color: subtitleColor, fontSize: 12),
            ),
            const SizedBox(height: 16),

            // سبب الإلغاء
            TextField(
              controller: _reasonController,
              maxLines: 3,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: "اكتب سبب الإلغاء هنا...".tr,
                hintStyle: TextStyle(color: subtitleColor),
                filled: true,
                fillColor: inputColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),

            const SizedBox(height: 16),

            // تصوير المنتج
            InkWell(
              onTap: _pickImage,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                height: _productImage != null ? 180 : 100,
                decoration: BoxDecoration(
                  color: inputColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _productImage != null
                        ? primaryColor
                        : (Get.isDarkMode ? Colors.white12 : const Color(0xFFE2E8F0)),
                  ),
                ),
                child: _productImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(_productImage!, fit: BoxFit.cover),
                            Positioned(
                              top: 8,
                              left: 8,
                              child: InkWell(
                                onTap: () =>
                                    setState(() => _productImage = null),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.close_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            color: subtitleColor,
                            size: 26,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "التقاط صورة المنتج".tr,
                            style: TextStyle(
                              color: subtitleColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_isValid && !_isSubmitting) ? _submit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.redAccent.withOpacity(0.4),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        "تأكيد الإلغاء".tr,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}