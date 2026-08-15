import 'dart:convert';
import 'package:delivery/core/services/local_storage.dart';
import 'package:delivery/data/datasource/remote/linkapi.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<dynamic> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  // 1. جلب التنبيهات من الـ Backend
  Future<void> _fetchNotifications() async {
    final String url =
        '${AppLink.deliveryStatus}/${LocalStorage.getUserId()}/notifications';

    try {
      final response = await http.get(Uri.parse(url));
      setState(() {
        _notifications = json.decode(response.body);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء الاتصال بالخادم: $e'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  // 2. تحديث حالة التنبيه إلى "مقروء" عند الضغط عليه
  Future<void> _markAsRead(int notificationId, int index) async {
    final String url =
        '${AppLink.deliveryStatus}/${LocalStorage.getUserId()}/notifications/read/$notificationId';

    try {
      final response = await http.put(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          _notifications[index]['read'] = true;
        });
      }
    } catch (e) {
      print('خطأ في تحديث حالة التنبيه: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // لون برتقالي عصري وتدرجات متناسقة تتماشى مع هويتك الأساسية
    const Color primaryColor = Color(0xFFFF5722);
    final isDark = Get.isDarkMode;
    final bgColor = Get.theme.scaffoldBackgroundColor;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final titleColor = isDark ? Colors.white : Colors.black;
    final unreadBgColor = isDark ? const Color(0xFF2D1610) : const Color(0xFFFFF3EE);
    final subTextColor = isDark ? Colors.white70 : Colors.grey;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          title: Text(
            'مركز التنبيهات',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          elevation: 0,
          backgroundColor: primaryColor,
          centerTitle: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(
                16,
              ), // انحناء خفيف لأسفل الـ AppBar ليعطيه طابعاً حديثاً
            ),
          ),
        ),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                ),
              )
            : _notifications.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // أيقونة دلالية ممتازة في حال عدم وجود تنبيهات
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.notifications_off_outlined,
                        size: 64,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'صندوق التنبيهات فارغ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'عندما تصلك تنبيهات جديدة ستظهر هنا فوراً',
                      style: TextStyle(fontSize: 14, color: subTextColor),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                color: primaryColor,
                onRefresh: _fetchNotifications,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final item = _notifications[index];
                    final bool isRead = item['read'] ?? false;

                    // معالجة آمنة للتاريخ في حال كان قادماً بشكل غير متوقع
                    String dateStr = item['createdAt']?.toString() ?? '';
                    if (dateStr.length > 10) dateStr = dateStr.substring(0, 10);

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      decoration: BoxDecoration(
                        color: isRead ? cardColor : unreadBgColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: isDark ? Colors.transparent : (isRead
                                ? Colors.black.withOpacity(0.04)
                                : primaryColor.withOpacity(0.08)),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          onTap: () {
                            if (!isRead) {
                              _markAsRead(item['id'], index);
                            }
                            // يمكنك توجيه المستخدم لصفحة الطلب هنا
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // أيقونة التنبيه محاطة بحاوية أنيقة تفاعلية
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isRead
                                        ? (isDark ? const Color(0xFF0F172A) : Colors.grey[100])
                                        : primaryColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    _getIconByType(item['type']),
                                    color: isRead
                                        ? (isDark ? Colors.white70 : Colors.grey[600])
                                        : primaryColor,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // محتوى التنبيه (العنوان والوصف والتاريخ)
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item['title'] ?? '',
                                              style: TextStyle(
                                                fontWeight: isRead
                                                    ? FontWeight.w600
                                                    : FontWeight.w800,
                                                fontSize: 15,
                                                color: isRead
                                                    ? textColor
                                                    : titleColor,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          // النقطة الصغيرة الدالة على عدم القراءة، تم نقلها بجانب العنوان بشكل أرتب
                                          if (!isRead)
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: const BoxDecoration(
                                                color: primaryColor,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        item['message'] ?? '',
                                        style: TextStyle(
                                          color: isRead
                                              ? subTextColor
                                              : textColor,
                                          fontSize: 13,
                                          height:
                                              1.4, // زيادة تباعد الأسطر لراحة العين أثناء القراءة
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      // قسم التاريخ بتصميم ناعم
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            size: 12,
                                            color: Colors.grey[400],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            dateStr,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[500],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }

  // تحديد الأيقونة بشكل يتناسب مع طبيعة التطبيقات الحديثة
  IconData _getIconByType(String? type) {
    switch (type) {
      case 'order':
        return Icons.local_shipping_rounded;
      case 'offer':
        return Icons.confirmation_number_rounded;
      case 'system':
        return Icons.gpp_good_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }
}
