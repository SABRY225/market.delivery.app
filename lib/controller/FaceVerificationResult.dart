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
      Get.snackbar('Error', 'Camera initialization error: $e');
    }
  }

  Future<void> processVerification() async {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      Get.snackbar('Alert', 'Camera not ready yet');
      return;
    }

    if (statusRequest == StatusRequest.loading) return;

    statusRequest = StatusRequest.loading;
    update();

    try {
      final image = await cameraController!.takePicture();

      final request = http.MultipartRequest('POST', Uri.parse(AppLink.verifyHuman));
      request.fields['userId'] = LocalStorage.getUserId().toString();

      request.files.add(
        await http.MultipartFile.fromPath('photo', image.path),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        statusRequest = StatusRequest.success;
        final data = jsonDecode(response.body);
        final bool isSuccess = data['success'] ?? false;
        final String message = data['message'] ?? 'Verified successfully';

        showResultDialog(
          title: isSuccess ? 'Verification successful ✅' : 'Verification failed ❌',
          content: message,
          isSuccess: isSuccess,
        );
         Get.offNamed(AppRoutes.home);
      } else {
        statusRequest = StatusRequest.serverfailure;
        final errorData = jsonDecode(response.body);
        final String errorMessage = errorData['message'] ?? 'Could not process order';

        showResultDialog(
          title: 'Face not recognized',
          content: errorMessage,
          isSuccess: false,
        );
      }
    } catch (e) {
      statusRequest = StatusRequest.offlinefailure;
      showResultDialog(
        title: 'Connection error',
        content: 'Check server connection and retry.',
        isSuccess: false,
      );
    } finally {
      statusRequest = StatusRequest.none;
      update();
    }
  }

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
          Get.back(); 
          if (isSuccess) {
            Get.until((route) => route.isFirst); 
          }
        },
        child: const Text('OK'),
      ),
    );
  }

  @override
  void onClose() {
    cameraController?.dispose();
    super.onClose();
  }
}