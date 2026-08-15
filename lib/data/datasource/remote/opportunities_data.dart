import 'package:delivery/core/class/crud.dart';
import 'package:delivery/data/datasource/remote/linkapi.dart';

class OpportunitiesData {
  Crud crud;
  OpportunitiesData(this.crud);

  Future<Object> getOpportunities() async {
    var response = await crud.getData(
      AppLink.opportunities,
    );
    return response.fold((l) => l, (r) => r);
  }

  Future<Object> acceptOpportunity(String opportunityId, String deliveryId) async {
    var response = await crud.postData(
      "${AppLink.acceptOpportunity}/$opportunityId/accept",
      {
        "deliveryId": deliveryId,
      },
    );
    return response.fold((l) => l, (r) => r);
  }
}
