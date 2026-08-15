import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/class/status_request.dart';
import 'package:delivery/controller/FaceVerificationResult.dart';

/// ألوان الهوية البصرية لشاشة التحقق — سهل تغييرها من مكان واحد
class _VerifyColors {
  static const bg = Color(0xFF0B0D14);
  static const primary = Color(0xFF00C2FF); // أزرق سايبر
  static const primaryDark = Color(0xFF0072FF);
  static const success = Color(0xFF2BD576);
  static const warning = Color(0xFFFFA13D);
  static const error = Color(0xFFFF5A5F);
  static const card = Color(0xFF141826);
}

class HumanVerificationScreen extends StatefulWidget {
  const HumanVerificationScreen({super.key});

  @override
  State<HumanVerificationScreen> createState() =>
      _HumanVerificationScreenState();
}

class _HumanVerificationScreenState extends State<HumanVerificationScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _scanController;

  @override
  void initState() {
    super.initState();
    Get.put(FaceVerificationController());

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scanController.dispose();
    super.dispose();
  }

  Color _statusColor(StatusRequest status) {
    switch (status) {
      case StatusRequest.loading:
        return _VerifyColors.warning;
      default:
        return _VerifyColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _VerifyColors.bg,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: GetBuilder<FaceVerificationController>(
        builder: (controller) {
          if (!controller.isCameraInitialized) {
            return _buildBootLoader();
          }

          final bool isLoading =
              controller.statusRequest == StatusRequest.loading;
          final Color accent = _statusColor(controller.statusRequest);

          return Stack(
            fit: StackFit.expand,
            children: [
              // 1) معاينة الكاميرا
              Transform.scale(
                scale: 1.2,
                child: Center(
                  child: CameraPreview(controller.cameraController!),
                ),
              ),

              // 2) تعتيم زجاجي حول إطار الوجه
              const _FaceScannerOverlay(),

              // 3) إطار المسح المتحرك
              Center(
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final glow = 0.35 + (_pulseController.value * 0.25);
                    return Container(
                      width: 280,
                      height: 380,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(
                          color: accent.withOpacity(0.8),
                          width: 3.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: accent.withOpacity(glow),
                            blurRadius: 36,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: child,
                    );
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      // خط المسح المتحرك أثناء التحميل
                      if (isLoading)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: AnimatedBuilder(
                            animation: _scanController,
                            builder: (context, _) {
                              return Align(
                                alignment: Alignment(
                                  0,
                                  -1 + (_scanController.value * 2),
                                ),
                                child: Container(
                                  height: 4,
                                  width: 260,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        accent.withOpacity(0),
                                        accent,
                                        accent.withOpacity(0),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      // أركان المسح الأربعة
                      ..._buildCorners(accent),
                    ],
                  ),
                ),
              ),

              // 4) الإرشادات العلوية
              Positioned(
                top: MediaQuery.of(context).padding.top + 70,
                left: 24,
                right: 24,
                child: Column(
                  children: [
                    _StatusPill(
                      isLoading: isLoading,
                      accent: accent,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'تأكد من وضوح الإضاءة وثبات الجهاز لأفضل نتيجة',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.55),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // 5) زر الالتقاط + بطاقة الإرشادات السفلية
              Positioned(
                bottom: 32,
                left: 24,
                right: 24,
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _InstructionsCard(isLoading: isLoading),
                      const SizedBox(height: 18),
                      _CaptureButton(
                        isLoading: isLoading,
                        onTap: controller.processVerification,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildCorners(Color accent) {
    const double offset = -2;
    const double length = 40;
    const double thickness = 5;

    Widget bracket({required Alignment alignment, required bool horizontal}) {
      return Positioned(
        top: alignment.y < 0 ? offset : null,
        bottom: alignment.y > 0 ? offset : null,
        left: alignment.x < 0 ? offset : null,
        right: alignment.x > 0 ? offset : null,
        child: Container(
          width: horizontal ? length : thickness,
          height: horizontal ? thickness : length,
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(2),
            boxShadow: [BoxShadow(color: accent, blurRadius: 8)],
          ),
        ),
      );
    }

    return [
      bracket(alignment: const Alignment(-1, -1), horizontal: true),
      bracket(alignment: const Alignment(-1, -1), horizontal: false),
      bracket(alignment: const Alignment(1, -1), horizontal: true),
      bracket(alignment: const Alignment(1, -1), horizontal: false),
      bracket(alignment: const Alignment(-1, 1), horizontal: true),
      bracket(alignment: const Alignment(-1, 1), horizontal: false),
      bracket(alignment: const Alignment(1, 1), horizontal: true),
      bracket(alignment: const Alignment(1, 1), horizontal: false),
    ];
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'التحقق الذكي من الهوية',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
          letterSpacing: 0.3,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        onPressed: () => Get.back(),
      ),
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(color: Colors.black.withOpacity(0.15)),
        ),
      ),
    );
  }

  Widget _buildBootLoader() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: _VerifyColors.primary),
          const SizedBox(height: 16),
          Text(
            'جاري تشغيل الكاميرا...',
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

/// شارة الحالة أعلى الشاشة (وضع الوجه / جاري الفحص)
class _StatusPill extends StatelessWidget {
  final bool isLoading;
  final Color accent;

  const _StatusPill({required this.isLoading, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isLoading ? Icons.sync : Icons.center_focus_strong_rounded,
            color: accent,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            isLoading ? 'جاري الفحص بالذكاء الاصطناعي...' : 'ضع وجهك في المنتصف',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// بطاقة إرشادات صغيرة فوق الزر تدي إحساس أكثر احترافية
class _InstructionsCard extends StatelessWidget {
  final bool isLoading;

  const _InstructionsCard({required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: isLoading
          ? const SizedBox.shrink()
          : Container(
              key: const ValueKey('instructions'),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _VerifyColors.card.withOpacity(0.85),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: _VerifyColors.primary, size: 18),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'انزع النظارة والكمامة إن وجدت، وتأكد إن وجهك بالكامل داخل الإطار',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

/// زر الالتقاط الرئيسي
class _CaptureButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _CaptureButton({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        height: 62,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _VerifyColors.card.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: _VerifyColors.warning,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'جاري التحقق من هويتك...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          height: 62,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [_VerifyColors.primary, _VerifyColors.primaryDark],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: _VerifyColors.primary.withOpacity(0.35),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt_rounded, color: Colors.black, size: 22),
              SizedBox(width: 10),
              Text(
                'التقاط وبدء التحقق',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HolePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.8);
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()
          ..addRRect(RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(size.width / 2, size.height / 2),
              width: 280,
              height: 380,
            ),
            const Radius.circular(40),
          ))
          ..close(),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// قناع تعتيم ناعم حول إطار الوجه لمنظر سينمائي احترافي
class _FaceScannerOverlay extends StatelessWidget {
  const _FaceScannerOverlay();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: HolePainter(),
      child: Container(),
    );
  }
}