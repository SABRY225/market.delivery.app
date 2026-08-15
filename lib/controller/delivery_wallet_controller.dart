import 'dart:convert';
import 'package:delivery/core/services/local_storage.dart';
import 'package:delivery/data/datasource/remote/linkapi.dart';
import 'package:delivery/data/model/order_wellet_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class DeliveryWalletController extends GetxController {
  double _receivedCustody = 0.0;
  List<OrderWeeletModel> _ordersLog = [];

  bool _isLoading = false;
  String? _errorMessage;

  // Getters للوصول المباشر من الواجهة
  double get receivedCustody => _receivedCustody;
  List<OrderWeeletModel> get ordersLog => _ordersLog;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get totalOrdersCount => _ordersLog.length;

  // حساب إجمالي التكاليف بأمان
  double get totalPaidToRestaurants {
    return _ordersLog.fold(
      0.0,
      (sum, order) => sum + order.totalPaidToRestaurant,
    );
  }

  // المبلغ المطلوب توريده
  double get amountToHandOver => _receivedCustody - totalPaidToRestaurants;

  @override
  void onInit() {
    super.onInit();
    fetchWalletData();
  }

  // جلب البيانات مع التعامل مع أخطاء السيرفر والشبكة
  Future<void> fetchWalletData() async {
    _isLoading = true;
    _errorMessage = null;
    update();

    try {
      final userId = LocalStorage.getUserId();
      final response = await http
          .get(
            Uri.parse('${AppLink.walletInfo}/$userId/wallet-info'),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        _receivedCustody =
            (data['receivedCustody'] as num?)?.toDouble() ?? 0.0;

        if (data['ordersLog'] != null && data['ordersLog'] is List) {
          _ordersLog = (data['ordersLog'] as List)
              .map((item) => OrderWeeletModel.fromJson(item))
              .toList();
        } else {
          _ordersLog = [];
        }
      } else {
        _errorMessage = 'فشل جلب البيانات من السيرفر (رمز: ${response.statusCode})';
      }
    } catch (e) {
      _errorMessage = 'تعذر الاتصال بالشبكة، تم إدراج بيانات مؤقتة.';
    } finally {
      _isLoading = false;
      update();
    }
  }

}