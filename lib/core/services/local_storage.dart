import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static late SharedPreferences prefs;

  static Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  static void setUser({
    required String token,
    required String email,
    required int userId,
    required String name,
    required bool online,
    required String workingMode,
    required String vehicleType,
  }) {
    prefs.setString('token', token);
    prefs.setString('email', email);
    prefs.setString('name', name);
    prefs.setString('workingMode', workingMode);
    prefs.setString('vehicleType', vehicleType);
    prefs.setInt('userId', userId);
    prefs.setBool('online', online);
  }
static Future<bool> setWorkingMode(String workingMode) async {
    return await prefs.setString('workingMode', workingMode);
  }
  static Future<bool> setVehicleType(String vehicleType) async {
    return await prefs.setString('vehicleType', vehicleType);
  }
  static void setPointAndOrders({
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
  static String? getWorkingMode() => prefs.getString('workingMode');
  static String? getVehicleType() => prefs.getString('vehicleType');
  static String? getOrderCounter() => prefs.getString('orderCounter');
  static int? getUserId() => prefs.getInt('userId');
  static bool? getOnline() => prefs.getBool('online');

  static Future<bool> setNotifications(bool enabled) async {
    return await prefs.setBool('notifications_enabled', enabled);
  }
  static bool getNotifications() => prefs.getBool('notifications_enabled') ?? true;

  static Future<bool> setDarkMode(bool enabled) async {
    return await prefs.setBool('dark_mode_enabled', enabled);
  }
  static bool getDarkMode() => prefs.getBool('dark_mode_enabled') ?? false;


  static void save(String key, List<String> value) {
    prefs.setStringList(key, value);
  }

  static List<String> get(String key) {
    return prefs.getStringList(key) ?? [];
  }

  static void clear() {
    prefs.clear();
  }
}