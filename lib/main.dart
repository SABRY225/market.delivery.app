import 'controller/locale_controller.dart';
import 'core/localization/translation.dart';
import 'core/services/local_storage.dart';
import 'core/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'routes.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:camera/camera.dart';

late CameraDescription firstCamera;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("New automatic alert and the app is closed: ${message.notification?.title}");
  if (message.notification != null) {
    NotificationService.showNotification(
      title: message.notification!.title ?? "",
      body: message.notification!.body ?? "",
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 

  try {
    final cameras = await availableCameras();
    firstCamera = cameras.firstWhere(
      (cam) => cam.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );
  } catch (e) {
    debugPrint("Camera initialization error: $e");
  }
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyBmJEbx3gCHxmjxQyg-oP2DKlHJPGXFh68',
      appId: '1:862339284408:web:8cd540137167fd488be34d',
      messagingSenderId: '862339284408',
      projectId: 'restaurant-3958c',
    ),
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  await LocalStorage.init(); 

  final LocaleController localeController = Get.put(LocaleController());

  String startRoute = await localeController.checkInitialRoute();

  await NotificationService.init();
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.notification != null) {
      NotificationService.showNotification(
        title: message.notification!.title ?? "",
        body: message.notification!.body ?? "",
      );
    }
  });
  runApp(AtelierApp(initialRoute: startRoute));
}

class AtelierApp extends StatelessWidget {
  final String initialRoute;

  const AtelierApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    LocaleController localeController = Get.find();

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Delivery',
      translations: MyTranslations(),
      locale: localeController.initialLocale,

      initialRoute: initialRoute,

      routes: AppRoutes.routes,

      themeMode: LocalStorage.getDarkMode() ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        primaryColor: const Color(0xFF002AFF),
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        primaryColor: const Color(0xFF002AFF),
      ),
    );
  }
}