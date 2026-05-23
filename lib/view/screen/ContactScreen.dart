import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  static const Color primaryColor = Color(0xFFFF5722);
  static const Color textColor = Color(0xFF1E293B);
  static const Color iconColor = Color(0xFF64748B);
  static const Color backgroundColor = Color.fromARGB(255, 238, 236, 236);

  final String phoneNumber = "+201012345678";
  final String whatsappNumber = "+201012345678";

  void _makePhoneCall() async {
    final Uri url = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      Get.snackbar("خطأ", "لا يمكن إجراء المكالمة حالياً");
    }
  }

  void _openWhatsApp() async {
    final Uri url = Uri.parse("https://wa.me/$whatsappNumber");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar("خطأ", "تطبيق واتساب غير مثبت أو لا يمكن فتح الرابط");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          "اتصل بنا".tr,
          style: const TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: textColor),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.support_agent_rounded,
                size: 80,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "الدعم الفني للمندوبين",
              style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "إذا كنت تواجه أي مشكلة في طلباتك أو حسابك، نحن هنا لمساعدتك على مدار الساعة.",
              textAlign: TextAlign.center,
              style: TextStyle(color: iconColor, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 40),
            _buildContactMethodCard(
              title: "اتصال هاتفي",
              subtitle: phoneNumber,
              icon: Icons.phone_forwarded_rounded,
              accentColor: primaryColor,
              onTap: _makePhoneCall,
            ),
            const SizedBox(height: 16),
            _buildContactMethodCard(
              title: "المحادثة عبر واتساب",
              subtitle: "تواصل معنا مباشرة عبر الدردشة",
              icon: Icons.chat_bubble_rounded,
              accentColor: const Color(0xFF25D366),
              onTap: _openWhatsApp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactMethodCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accentColor, size: 26),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: iconColor, fontSize: 13),
                ),
              ],
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: iconColor,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
