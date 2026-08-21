import 'package:delivery/core/services/local_storage.dart';
import 'package:delivery/data/datasource/remote/linkapi.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';

class MessageModel {
  final int id;
  final String messageText;
  final int senderId;
  final String senderName;
  final String senderRole;
  final bool isSentByMe;
  final String createdAt;

  MessageModel({
    required this.id,
    required this.messageText,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.isSentByMe,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      messageText: json['messageText'],
      senderId: json['senderId'],
      senderName: json['senderName'] ?? '',
      senderRole: json['senderRole'] ?? '',
      isSentByMe: json['isSentByMe'] ?? false,
      createdAt: json['createdAt'] ?? '',
    );
  }
}

class SupportController extends GetxController {
  var messages = <MessageModel>[].obs;
  var isLoading = false.obs;
  var isSending = false.obs;

  final TextEditingController messageInputController = TextEditingController();

  final currentUserId = LocalStorage.getUserId();

  @override
  void onInit() {
    super.onInit();
    fetchChatHistory();
  }

  Future<void> fetchChatHistory() async {
    try {
      isLoading.value = true;
      final url = '${AppLink.contact}/driver/history';
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${LocalStorage.getToken()}',
      };

      print('=============================================');
      print('🚀 [API REQUEST] GET $url');
      print('Headers: $headers');

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      print('📦 [API RESPONSE] Status: ${response.statusCode}');
      print('Body: ${response.body}');
      print('=============================================');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          List list = data['data'];
          messages.value = list.map((m) => MessageModel.fromJson(m)).toList();
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        LocalStorage.clear();
        Get.offAllNamed('/login'); 
        Get.snackbar(
          'Alert', 
          'Session expired, please login again',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar('Error', 'Failed to fetch chat log', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      print('🔴 [API ERROR] $e');
      Get.snackbar('Error', 'Network connection error', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

Future<void> sendMessage() async {
  final text = messageInputController.text.trim();
  if (text.isEmpty) return;

  final token = LocalStorage.getToken();
  if (token == null || token.isEmpty) {
    Get.snackbar('Alert', 'Session expired, please login again', snackPosition: SnackPosition.BOTTOM);
    return;
  }

  try {
    isSending.value = true;

    final url = '${AppLink.contact}/driver/message';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final body = json.encode({'messageText': text});

    print('=============================================');
    print('🚀 [API REQUEST] POST $url');
    print('Headers: $headers');
    print('Body: $body');

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    print('📦 [API RESPONSE] Status: ${response.statusCode}');
    print('Body: ${response.body}');
    print('=============================================');

    if (response.statusCode == 200 || response.statusCode == 201) {
      messageInputController.clear(); 
      await fetchChatHistory();
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      LocalStorage.clear();
      Get.offAllNamed('/login');
      Get.snackbar(
        'Alert',
        'Session expired, please login again',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      String errorMessage = 'Could not send message, try again.';
      try {
        final decoded = json.decode(response.body);
        if (decoded['message'] != null) {
          errorMessage = decoded['message'];
        } else if (decoded['error'] != null) {
          errorMessage = decoded['error'];
        }
      } catch (_) {}
      Get.snackbar(
        'Sending error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  } catch (e) {
    print('🔴 [API ERROR] $e');
    Get.snackbar(
      'Connection Problem',
      'Check internet and try again.',
      snackPosition: SnackPosition.BOTTOM,
    );
  } finally {
    isSending.value = false;
  }
}
  @override
  void onClose() {
    messageInputController.dispose();
    super.onClose();
  }
}