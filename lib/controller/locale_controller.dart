import '../../../routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController extends GetxController {
  Locale? initialLocale;

  static const String langKey = "lang";
  static const String tokenKey = "token";

  @override
  void onInit() {
    super.onInit();
    getSavedLocale();
  }

  void getSavedLocale() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sharedPrefLang = prefs.getString(langKey);

    if (sharedPrefLang == "ar") {
      initialLocale = const Locale("ar");
    } else if (sharedPrefLang == "en") {
      initialLocale = const Locale("en");
    } else {
      initialLocale = Locale(Get.deviceLocale!.languageCode);
    }
    update();
  }

  void changeLang(String langCode) async {
    Locale locale = Locale(langCode);
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString(langKey, langCode);

    Get.updateLocale(locale);

    String? token = prefs.getString(tokenKey);

    if (token != null && token.isNotEmpty) {
      Get.offAllNamed(AppRoutes.home);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  Future<String> checkInitialRoute() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String? lang = prefs.getString(langKey);
    String? token = prefs.getString(tokenKey);

    if (lang == null) {
      return AppRoutes.language;
    }

    if (token != null && token.isNotEmpty) {
      return AppRoutes.home;
    } else {
      return AppRoutes.login;
    }
  }
}
