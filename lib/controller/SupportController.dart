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

  // قم بتمرير userId عند فتح الشاشة
  final currentUserId = LocalStorage.getUserId();

  @override
  void onInit() {
    super.onInit();
    fetchChatHistory();
  }

  // 1. جلب سجل الرسائل
  Future<void> fetchChatHistory() async {
    try {
      isLoading.value = true;
      final response = await http.get(
        Uri.parse('${AppLink.contact}/driver/history'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${LocalStorage.getToken()}',
        },
      );
    print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          List list = data['data'];
          messages.value = list.map((m) => MessageModel.fromJson(m)).toList();
        }
      } else {
        Get.snackbar('خطأ', 'فشل في جلب سجل المحادثة');
      }
    } catch (e) {
      Get.snackbar('خطأ', 'حدث خطأ في الاتصال بالشبكة');
    } finally {
      isLoading.value = false;
    }
  }

  // 2. إرسال رسالة جديدة من العميل
Future<void> sendMessage() async {
  final text = messageInputController.text.trim();
  if (text.isEmpty) return;

  final token = LocalStorage.getToken();
  if (token == null || token.isEmpty) {
    Get.snackbar('خطأ', 'جلسة الدخول منتهية، يرجى إعادة التسجيل');
    return;
  }

  try {
    isSending.value = true;

    final response = await http.post(
      Uri.parse('${AppLink.contact}/driver/message'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'messageText': text}),
    );


    if (response.statusCode == 200 || response.statusCode == 201) {
      messageInputController.clear(); // مسح الإدخال فقط عند النجاح
      await fetchChatHistory();
    } else if (response.statusCode == 403) {
      Get.snackbar('خطأ', 'ليس لديك صلاحية للوصول لهذا الدعم');
    } else {
      Get.snackbar('خطأ', 'تعذر إرسال الرسالة: ${response.statusCode}');
    }
  } catch (e) {
    Get.snackbar('خطأ', 'حدث خطأ أثناء الإرسال');
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
