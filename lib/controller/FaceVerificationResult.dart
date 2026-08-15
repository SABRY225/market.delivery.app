import 'dart:async';
import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:delivery/data/datasource/remote/linkapi.dart';
import 'package:delivery/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:delivery/core/services/local_storage.dart';
import '../../../core/class/status_request.dart';

class FaceVerificationController extends GetxController {
  StatusRequest statusRequest = StatusRequest.none;

  CameraController? cameraController;
  bool isCameraInitialized = false;

  @override
  void onInit() {
    initFrontCamera();
    super.onInit();
  }

  // 1. تهيئة الكاميرا الأمامية
  Future<void> initFrontCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await cameraController!.initialize();
      isCameraInitialized = true;
      update();
    } catch (e) {
      Get.snackbar('خطأ', 'حدث خطأ أثناء تهيئة الكاميرا: $e');
    }
  }

  // 2. التقاط صورة الوجه وإرسالها لإثبات البصرية
  Future<void> processVerification() async {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      Get.snackbar('تنبيـه', 'الكاميرا غير جاهزة بعد');
      return;
    }

    if (statusRequest == StatusRequest.loading) return;

    statusRequest = StatusRequest.loading;
    update();

    try {
      // التقاط صورة الوجه الحالية
      final image = await cameraController!.takePicture();

      // تجهيز الـ Multipart Request
      final request = http.MultipartRequest('POST', Uri.parse(AppLink.verifyHuman));
      
      // إرسال معرف المستخدم
      request.fields['userId'] = LocalStorage.getUserId().toString();

      // إرسال صورة واحدة باسم 'photo' ليتطابق مع req.file و upload.single('photo')
      request.files.add(
        await http.MultipartFile.fromPath('photo', image.path),
      );

      // إرسال الطلب
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        statusRequest = StatusRequest.success;
        final data = jsonDecode(response.body);
        final bool isSuccess = data['success'] ?? false;
        final String message = data['message'] ?? 'تم التحقق بنجاح';

        showResultDialog(
          title: isSuccess ? 'تم التثبت بنجاح ✅' : 'فشل التحقق ❌',
          content: message,
          isSuccess: isSuccess,
        );
         Get.offNamed(AppRoutes.home);
      } else {
        statusRequest = StatusRequest.serverfailure;
        final errorData = jsonDecode(response.body);
        final String errorMessage = errorData['message'] ?? 'تعذر معالجة الطلب';

        showResultDialog(
          title: 'لم نتمكن من التعرف على وجه',
          content: errorMessage,
          isSuccess: false,
        );
      }
    } catch (e) {
      statusRequest = StatusRequest.offlinefailure;
      showResultDialog(
        title: 'خطأ في الاتصال',
        content: 'تأكد من الاتصال بالسيرفر وأعد المحاولة.',
        isSuccess: false,
      );
    } finally {
      statusRequest = StatusRequest.none;
      update();
    }
  }

  // 3. عرض النتيجة للمستخدم
  void showResultDialog({
    required String title,
    required String content,
    required bool isSuccess,
  }) {
    Get.defaultDialog(
      title: title,
      content: Text(content, textAlign: TextAlign.center),
      barrierDismissible: false,
      confirm: TextButton(
        onPressed: () {
          Get.back(); // إغلاق الـ Dialog
          if (isSuccess) {
            Get.until((route) => route.isFirst); // العودة للشاشة الرئيسية
          }
        },
        child: const Text('موافق'),
      ),
    );
  }

  @override
  void onClose() {
    cameraController?.dispose();
    super.onClose();
  }
}