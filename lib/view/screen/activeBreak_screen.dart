import 'package:flutter/material.dart';
import 'package:timer_count_down/timer_count_down.dart';
import 'package:get/get.dart';

class ActiveBreakScreen extends StatelessWidget {
  final int durationInMinutes;

  const ActiveBreakScreen({super.key, required this.durationInMinutes});

  @override
  Widget build(BuildContext context) {
    int durationInSeconds = durationInMinutes * 60;

    final isDark = Get.isDarkMode;
    final backgroundColor = isDark ? const Color(0xFF0F172A) : Get.theme.scaffoldBackgroundColor;
    final surfaceColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    const accentColor = Color(0xFFFF5722);
    const warningColor = Color(0xFFF59E0B);
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.blueGrey[200] : Colors.blueGrey[600];

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // الجزء العلوي: الأيقونة والرسالة
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.transparent : Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.coffee_outlined,
                      size: 64,
                      color: warningColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'أنت الآن في فترة استراحة',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'خذ قسطاً من الراحة، سيتم إعادتك للعمل تلقائياً فور انتهاء العداد.',
                      style: TextStyle(
                        fontSize: 14,
                        color: subTextColor,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // العداد التنازلي مع تأثير التصميم الدائري
              Countdown(
                seconds: durationInSeconds,
                interval: const Duration(seconds: 1),
                build: (BuildContext context, double time) {
                  int minutes = (time / 60).floor();
                  int seconds = (time % 60).floor();
                  String timeStr =
                      '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

                  // حساب النسبة المئوية للمؤشر الدائري
                  double progress = time / durationInSeconds;

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // حلقة التقدم الخلفية الباهتة
                      SizedBox(
                        width: 220,
                        height: 220,
                        child: CircularProgressIndicator(
                          value: 1.0,
                          strokeWidth: 8,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            surfaceColor,
                          ),
                        ),
                      ),
                      // حلقة التقدم الأمامية المتحركة
                      SizedBox(
                        width: 220,
                        height: 220,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 8,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            accentColor,
                          ),
                          strokeCap: StrokeCap.round, // أطراف دائرية ناعمة للمؤشر
                        ),
                      ),
                      // النص الداخلي للعداد
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            timeStr,
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              color: textColor,
                              fontFamily: 'monospace', // لثبات أبعاد الأرقام أثناء التغير
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'متبقي',
                            style: TextStyle(
                              fontSize: 14,
                              color: subTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
                onFinished: () {
                  _showFinishSnackBar(context);
                  Navigator.of(context).pop();
                },
              ),

              const Spacer(),

              // زر إنهاء الاستراحة مبكراً (مهم جداً للمندوب إذا أراد العودة للعمل سريعاً)
              OutlinedButton.icon(
                onPressed: () {
                  _showFinishSnackBar(context);
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.flash_on_rounded, size: 20, color: accentColor),
                label: Text(
                  'إنهاء الاستراحة والعودة للعمل',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: accentColor, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  void _showFinishSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 10),
            Text('تم إنهاء الاستراحة! بالتوفيق في عملك.'),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}