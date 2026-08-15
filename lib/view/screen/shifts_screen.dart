import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ShiftsScreen extends StatefulWidget {
  const ShiftsScreen({super.key});

  @override
  State<ShiftsScreen> createState() => _ShiftsScreenState();
}

class _ShiftsScreenState extends State<ShiftsScreen> {
  List<Map<String, dynamic>> monthDays = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _generateMonthDays();
    // Scroll to today's date after a short delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      int todayIndex = DateTime.now().day - 1;
      if (todayIndex > 0 && _scrollController.hasClients) {
        _scrollController.animateTo(
          todayIndex * 120.0, // rough estimate of item height
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  String _getArabicDayName(int weekday) {
    switch (weekday) {
      case 1: return "الإثنين";
      case 2: return "الثلاثاء";
      case 3: return "الأربعاء";
      case 4: return "الخميس";
      case 5: return "الجمعة";
      case 6: return "السبت";
      case 7: return "الأحد";
      default: return "";
    }
  }

  String _getMonthName(int month) {
    List<String> months = ["يناير", "فبراير", "مارس", "أبريل", "مايو", "يونيو", "يوليو", "أغسطس", "سبتمبر", "أكتوبر", "نوفمبر", "ديسمبر"];
    return months[month - 1];
  }

  void _generateMonthDays() {
    DateTime now = DateTime.now();
    int lastDay = DateTime(now.year, now.month + 1, 0).day;
    
    for (int i = 1; i <= lastDay; i++) {
      DateTime date = DateTime(now.year, now.month, i);
      monthDays.add({
        'date': date,
        'dayName': _getArabicDayName(date.weekday),
        'dayNumber': i.toString(),
        'active': false,
        'start': '08:00 AM',
        'end': '04:00 PM',
      });
    }
  }

  Future<void> _selectTime(BuildContext context, int index, bool isStart) async {
    TimeOfDay initialTime = TimeOfDay.now();
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF5722),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        String formattedTime = picked.format(context);
        if (isStart) {
          monthDays[index]['start'] = formattedTime;
        } else {
          monthDays[index]['end'] = formattedTime;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String currentMonthName = _getMonthName(now.month);

    final isDark = Get.isDarkMode;
    final bgColor = Get.theme.scaffoldBackgroundColor;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark ? Colors.white70 : Colors.black54;
    final shadowColor = isDark ? Colors.transparent : Colors.black.withOpacity(0.02);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text("جدول شهر $currentMonthName".tr, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: cardColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: cardColor,
              boxShadow: [
                BoxShadow(color: shadowColor, blurRadius: 4, offset: const Offset(0, 2))
              ]
            ),
            child: Text(
              "قم بتفعيل الأيام التي ترغب بالعمل فيها خلال هذا الشهر، وحدد أوقات البداية والنهاية لكل يوم.",
              style: TextStyle(color: subTextColor, fontSize: 13, height: 1.5),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: monthDays.length,
              itemBuilder: (context, index) {
                var day = monthDays[index];
                bool isActive = day['active'];
                DateTime dayDate = day['date'];
                bool isToday = dayDate.year == now.year && dayDate.month == now.month && dayDate.day == now.day;
                bool isPast = dayDate.isBefore(DateTime(now.year, now.month, now.day));

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isPast ? (isDark ? Colors.grey[800] : Colors.grey[100]) : cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isActive ? const Color(0xFFFF5722).withOpacity(0.4) : (isToday ? Colors.blue.withOpacity(0.3) : (isDark ? Colors.white10 : Colors.transparent))),
                    boxShadow: [
                      if (!isPast) BoxShadow(color: shadowColor, blurRadius: 8, offset: const Offset(0, 4))
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                color: isToday ? Colors.blue.withOpacity(0.1) : (isActive ? const Color(0xFFFF5722).withOpacity(0.1) : (isDark ? Colors.white10 : Colors.grey[100])),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    day['dayNumber'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: isToday ? Colors.blue : (isActive ? const Color(0xFFFF5722) : textColor),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    day['dayName'],
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: isPast ? Colors.grey : textColor,
                                    ),
                                  ),
                                  if (isToday)
                                    Text("اليوم", style: TextStyle(color: Colors.blue, fontSize: 11, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            if (!isPast)
                              Switch(
                                value: isActive,
                                activeThumbColor: const Color(0xFFFF5722),
                                onChanged: (val) {
                                  setState(() {
                                    monthDays[index]['active'] = val;
                                  });
                                },
                              ),
                          ],
                        ),
                        if (isActive && !isPast) ...[
                          Divider(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => _selectTime(context, index, true),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("وقت البدء", style: TextStyle(color: Colors.grey, fontSize: 11)),
                                        const SizedBox(height: 4),
                                        Text(day['start'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFFF5722))),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: InkWell(
                                  onTap: () => _selectTime(context, index, false),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("وقت الانتهاء", style: TextStyle(color: Colors.grey, fontSize: 11)),
                                        const SizedBox(height: 4),
                                        Text(day['end'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFFF5722))),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ]
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              boxShadow: [
                BoxShadow(color: shadowColor, blurRadius: 10, offset: const Offset(0, -5))
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5722),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: () {
                  Get.snackbar(
                    "تم الحفظ بنجاح",
                    "تم تحديث جدول عملك لهذا الشهر بنجاح.",
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM,
                    margin: const EdgeInsets.all(16),
                  );
                },
                child: Text(
                  "اعتماد جدول الشهر",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
