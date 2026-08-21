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

  double get receivedCustody => _receivedCustody;
  List<OrderWeeletModel> get ordersLog => _ordersLog;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get totalOrdersCount => _ordersLog.length;

  double get totalPaidToRestaurants {
    return _ordersLog.fold(
      0.0,
      (sum, order) => sum + order.totalPaidToRestaurant,
    );
  }

  double get amountToHandOver => _receivedCustody - totalPaidToRestaurants;

  @override
  void onInit() {
    super.onInit();
    fetchWalletData();
  }

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
        _errorMessage = 'Server data fetch failed: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Network error, temp data added.';
    } finally {
      _isLoading = false;
      update();
    }
  }

}