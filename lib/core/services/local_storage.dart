import 'dart:ffi';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static late SharedPreferences prefs;

  static init() async {
    prefs = await SharedPreferences.getInstance();
  }

  static setUser({
    required String token,
    required String email,
    required int userId,
    required String name,
    required bool online,
  }) {
    prefs.setString('token', token);
    prefs.setString('email', email);
    prefs.setString('name', name);
    prefs.setInt('userId', userId);
    prefs.setBool('online', online);
  }

  static setPointAndOrders({
    required String points,
    required String orderCounter,
  }) {
    prefs.setString('points', points);
    prefs.setString('orderCounter', orderCounter);
  }

  static String? getToken() => prefs.getString('token');
  static String? getEmail() => prefs.getString('email');
  static String? getName() => prefs.getString('name');
  static String? getPoints() => prefs.getString('points');
  static String? getOrderCounter() => prefs.getString('orderCounter');
  static int? getUserId() => prefs.getInt('userId');
  static bool? getOnline() => prefs.getBool('online');

  static clear() {
    prefs.clear();
  }
}