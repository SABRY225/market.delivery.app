import 'package:get/get.dart';
import '../../core/class/status_request.dart';
import '../../core/functions/handling_data_controller.dart';
import '../../data/datasource/remote/info_delivery_data.dart';
import '../../core/class/crud.dart';

class InfoDeliveryController extends GetxController {
  InfoDeliveryData infoDeliveryData = InfoDeliveryData(Crud());
  StatusRequest statusRequest = StatusRequest.none;
  Map<String, dynamic> driverData = {};

  getDriverProfile() async {
    statusRequest = StatusRequest.loading;
    update();

    var response = await infoDeliveryData.getProfile();
    statusRequest = handlingData(response);

    if (StatusRequest.success == statusRequest) {
      if (response['status'] == "success" && response['data'] != null) {
        driverData = response['data'];
      } else {
        statusRequest = StatusRequest.failure;
      }
    } else {
      loadTemporaryDriverData();
    }
    update();
  }

  @override
  void onInit() {
    getDriverProfile();
    super.onInit();
  }

  void loadTemporaryDriverData() {
    statusRequest = StatusRequest.success;
    driverData = {
      "id": 1,
      "user_id": 11,
      "username": "Ahmed Ali",
      "email": "ahmed.delivery@test.com",
      "phone": "01012345678",
      "whatsapp": "01012345678",
      "dob": "1998-05-12",
      "documentsVerified": false,
      "rating": "5.0",
      "lastSeen": null,
      "gender": "male",
      "vehicleType": "motorcycle",
      "vehicleColor": "Red",
      "plateNumber": "ABC-1234",
      "idExpiry": "2028-05-01",
      "licenseExpiry": "2027-03-01",
      "vehicleLicenseExpiry": "2026-12-01",
      "latitude": "30.02838100",
      "longitude": "31.26227400",
      "operatingArea": "Nasr City",
      "workType": "full_time",
      "dailyHours": 8,
      "workingDays": "[\"sat\",\"sun\",\"mon\",\"tue\",\"wed\"]",
      "online": true,
      "is_busy": false,
      "accountStatus": "approved",
      "createdAt": "2026-02-13T09:33:12.000Z",
      "updatedAt": "2026-05-22T16:55:34.000Z"
    };
    update();
  }
}
