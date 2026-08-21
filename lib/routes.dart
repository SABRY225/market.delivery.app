import 'package:delivery/view/screen/ContactScreen.dart';
import 'package:delivery/view/screen/HumanVerificationScreen.dart';
import 'package:delivery/view/screen/InfoDeliveryScreen.dart';
import 'package:delivery/view/screen/StatisticsScreen.dart';
import 'package:delivery/view/screen/deliveryWallet_screen.dart';
import 'package:delivery/view/screen/notifications_screen.dart';
import 'package:delivery/view/screen/order_details_screen.dart';
import 'package:flutter/material.dart';
import 'view/screen/LanguageScreen.dart';
import 'view/screen/settingsLanguageScreen.dart';
import 'view/screen/home_screen.dart';
import 'view/screen/profile_screen.dart';
import 'view/screen/auth/login_screen.dart';
import 'view/screen/orders_screen.dart';
import 'view/screen/breakSelection_screen.dart';
import 'view/screen/shifts_screen.dart';
import 'view/screen/opportunities_screen.dart';
import 'view/screen/settings_screen.dart';
import 'view/screen/trip_details_screen.dart';

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
  static const String wallet = "/wallet";
  static const String schedule = "/schedule";
  static const String notification = "/notification";
  static const String idscan = "/idscan";
  static const String shifts = "/shifts";
  static const String opportunities = "/opportunities";
  static const String settings = "/settings";

  static const String tripDetails = "/trip-details";

  static Map<String, Widget Function(BuildContext)> routes = {
    login: (context) => const LoginScreen(),
    home: (context) => const HomeScreen(),
    orders: (context) => const OrdersScreen(),
    profile: (context) => const ProfileScreen(),
    statistics: (context) => const StatisticsScreen(),
    language: (context) => const LanguageScreen(),
    selectLanguage: (context) => const SettingsLanguageScreen(),
    settings: (context) => const SettingsScreen(),
    infoDelivery: (context) => const InfoDeliveryScreen(),
    contact: (context) => const SupportChatScreen(),
    notification: (context) => const NotificationsScreen(),
    schedule: (context) => const BreakSelectionScreen(),
    wallet: (context) => const DeliveryWalletScreen(),
    idscan: (context) => HumanVerificationScreen(),
    detailesOrder: (context) => OrderDetailsScreen(),
    tripDetails: (context) => const TripDetailsScreen(),
    shifts: (context) => const ShiftsScreen(),
    opportunities: (context) => const OpportunitiesScreen(),
  };
}