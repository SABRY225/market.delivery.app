import 'package:delivery/core/functions/handling_data_controller.dart';
import 'package:get/get.dart';
import '../../core/class/status_request.dart';
import '../../data/datasource/remote/home_data.dart';

class TripDetailsController extends GetxController {
  final HomeData homeData;
  TripDetailsController({required this.homeData});

  StatusRequest statusRequest = StatusRequest.none;
  late String tripId;
  Map tripDetails = {};

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args["tripId"] != null) {
      tripId = args["tripId"].toString();
      getTripDetails();
    } else {
      statusRequest = StatusRequest.failure;
      update();
    }
  }

  Future<void> getTripDetails() async {
    statusRequest = StatusRequest.loading;
    update();

    var response = await homeData.getTripDetails(tripId);
    statusRequest = handlingData(response);

    if (statusRequest == StatusRequest.success) {
      if (response is Map && response['success'] == true) {
        tripDetails = response['data'] ?? {};
      } else {
        statusRequest = StatusRequest.failure;
      }
    }
    update();
  }
}