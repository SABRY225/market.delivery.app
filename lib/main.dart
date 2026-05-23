import 'controller/locale_controller.dart';
import 'core/services/notification_service.dart';
import 'core/localization/translation.dart';
import 'core/services/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalStorage.init(); 

  final LocaleController localeController = Get.put(LocaleController());

  String startRoute = await localeController.checkInitialRoute();

  await NotificationService.init();
  
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

      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.orange,
      ),
    );
  }
}
