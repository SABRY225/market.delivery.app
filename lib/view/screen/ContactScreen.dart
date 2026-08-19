import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:delivery/controller/SupportController.dart';

class SupportChatScreen extends StatelessWidget {
  const SupportChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SupportController controller = Get.put(SupportController());
    final theme = Theme.of(context);
    final isDark = Get.isDarkMode;
    final bgColor = Get.theme.scaffoldBackgroundColor;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: cardColor,
        centerTitle: false,
        titleSpacing: 0,
        iconTheme: IconThemeData(color: textColor),
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: theme.primaryColor.withOpacity(0.1),
                  child: Icon(Icons.headset_mic_rounded, color: theme.primaryColor),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'delegate_support'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'quick_reply_online'.tr,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: textColor),
            tooltip: 'تحديث',
            onPressed: () => controller.fetchChatHistory(),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // قائمة الرسائل
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }

              if (controller.messages.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final msg = controller.messages[index];
                  return _buildMessageBubble(context, msg);
                },
              );
            }),
          ),

          // اقتراحات الرد السريع للمندوب
          _buildQuickReplies(controller),

          // شريط إدخال الرسالة
          _buildInputBar(context, controller),
        ],
      ),
    );
  }


  // ردود سريعة بضغطة زر دون الحاجة للكتابة أثناء القيادة
  Widget _buildQuickReplies(SupportController controller) {
    final isDark = Get.isDarkMode;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    
    final List<String> quickMessages = [
      'customer_not_answering'.tr,
      'address_not_clear'.tr,
      'delay_in_receiving_order'.tr,
      'payment_problem'.tr,
    ];

    return Container(
      height: 40,
      margin: const EdgeInsets.only(bottom: 6),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: quickMessages.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final text = quickMessages[index];
          return ActionChip(
            backgroundColor: cardColor,
            elevation: 1,
            side: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade300),
            label: Text(
              text,
              style: TextStyle(fontSize: 12, color: textColor),
            ),
            onPressed: () {
              controller.messageInputController.text = text;
              controller.sendMessage();
            },
          );
        },
      ),
    );
  }

  // شاشة الفراغ
  Widget _buildEmptyState() {
    final isDark = Get.isDarkMode;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.support_agent_rounded,
                size: 56,
                color: Colors.blue.shade600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'welcome_to_delegate_support'.tr,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'choose_quick_reply_msg'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // فقاعة الرسالة
  Widget _buildMessageBubble(BuildContext context, dynamic message) {
    final bool isMe = message.isSentByMe;
    final primaryColor = Theme.of(context).primaryColor;
    final isDark = Get.isDarkMode;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe) ...[
                CircleAvatar(
                  radius: 14,
                  backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.blue.shade100,
                  child: Icon(Icons.headset_mic, size: 15, color: Colors.blue),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.78,
                  ),
                  decoration: BoxDecoration(
                    color: isMe ? primaryColor : cardColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.transparent : Colors.black.withOpacity(0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isMe && (message.senderName?.isNotEmpty ?? false)) ...[
                        Text(
                          message.senderName,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.blue.shade300 : Colors.blue.shade700,
                          ),
                        ),
                        const SizedBox(height: 3),
                      ],
                      Text(
                        message.messageText ?? '',
                        style: TextStyle(
                          color: isMe ? Colors.white : textColor,
                          fontSize: 14,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // شريط الإدخال
  Widget _buildInputBar(BuildContext context, SupportController controller) {
    final primaryColor = Theme.of(context).primaryColor;
    final isDark = Get.isDarkMode;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final inputBgColor = isDark ? const Color(0xFF0F172A) : Colors.grey.shade100;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.transparent : Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: inputBgColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: controller.messageInputController,
                  maxLines: 3,
                  minLines: 1,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: 'write_support_message'.tr,
                    hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.grey.shade500, fontSize: 14),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Obx(() {
              final bool isSending = controller.isSending.value;
              return Material(
                color: isSending ? Colors.grey.shade300 : primaryColor,
                shape: const CircleBorder(),
                elevation: 1,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: isSending ? null : () => controller.sendMessage(),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}