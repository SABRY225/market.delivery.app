import 'package:delivery/view/screen/ContactScreen.dart';
import 'package:delivery/view/screen/InfoDeliveryScreen.dart';
import 'package:delivery/view/screen/StatisticsScreen.dart';
import 'package:delivery/view/screen/order_details_screen.dart';
import 'package:flutter/material.dart';
import 'view/screen/LanguageScreen.dart';
import 'view/screen/settingsLanguageScreen.dart';
import 'view/screen/home_screen.dart';
import 'view/screen/profile_screen.dart';
import 'view/screen/auth/login_screen.dart';
import 'view/screen/orders_screen.dart';


class AppRoutes {
  static const String login = "/login";
  static const String home = "/home";
  static const String orders = "/orders";
  static const String profile = "/profile";
  static const String language = "/language";
  static const String categoryProducts = "/category";
  static const String selectLanguage = "/select-language";
  static const String infoDelivery = "/info_delivery";
  static const String statistics = "/statistics";
  static const String contact = "/contact";
  static const String detailesOrder = "/details-order";
  
  static Map<String, Widget Function(BuildContext)> routes = {
    login: (context) => const LoginScreen(),
    home: (context) => const HomeScreen(),
    orders: (context) => const OrdersScreen(),
    profile: (context) => const ProfileScreen(),
    statistics: (context) => const StatisticsScreen(),
    language: (context) => const LanguageScreen(),
    selectLanguage: (context) => const SettingsLanguageScreen(),
    infoDelivery: (context) => const InfoDeliveryScreen(),
    contact: (context) => const ContactScreen(),
    detailesOrder: (context) => const OrderDetailsScreen(),
  };
}