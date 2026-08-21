import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../../../routes.dart';
import '../services/local_storage.dart';
import 'status_request.dart';

class Crud {
  Map<String, String> _getHeaders() {
    String? token = LocalStorage.getToken();
    if (token != null && token.isNotEmpty) {
      return {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      };
    }
    return {"Content-Type": "application/json"};
  }

  void _logRequest(String method, String url, Map<String, String> headers, [Object? body]) {
    print('=============================================');
    print(' [API REQUEST] $method $url');
    print('Headers: $headers');
    if (body != null) {
      print('Body: $body');
    }
  }

  void _logResponse(http.Response response) {
    print(' [API RESPONSE] Status: ${response.statusCode}');
    print('Body: ${response.body}');
    print('=============================================');
  }

  bool _checkUnauthorized(http.Response response) {
    if (response.statusCode == 401 || response.statusCode == 403) {
      LocalStorage.clear();
      Get.offAllNamed(AppRoutes.login);
      Get.snackbar(
        "Error", 
        "Session expired, please login again",
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    }
    return false;
  }

  Future<Either<StatusRequest, Map>> postData(String linkurl, Map data) async {
    try {
      final headers = _getHeaders();
      final body = jsonEncode(data);
      _logRequest('POST', linkurl, headers, body);
      var response = await http.post(
        Uri.parse(linkurl),
        headers: headers,
        body: body,
      );
      _logResponse(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Map responsebody = jsonDecode(response.body);
        return Right(responsebody);
      } else if (_checkUnauthorized(response)) {
        return const Left(StatusRequest.serverfailure);
      } else {
        return const Left(StatusRequest.serverfailure);
      }
    } catch (e) {
      print('🔴 [API ERROR] $e');
      return const Left(StatusRequest.offlinefailure);
    }
  }

  Future<Either<StatusRequest, Map>> putData(
    String linkurl,
    bool online,
  ) async {
    try {
      final headers = _getHeaders();
      final body = jsonEncode({"online": online});
      _logRequest('PUT', linkurl, headers, body);
      var response = await http.put(
        Uri.parse(linkurl),
        headers: headers,
        body: body,
      );
      _logResponse(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Map responsebody = jsonDecode(response.body);
        return Right(responsebody);
      } else if (_checkUnauthorized(response)) {
        return const Left(StatusRequest.serverfailure);
      } else {
        return const Left(StatusRequest.serverfailure);
      }
    } catch (e) {
      print('🔴 [API ERROR] $e');
      return const Left(StatusRequest.offlinefailure);
    }
  }

  Future<Either<StatusRequest, Map>> patchData(
    String linkurl,
    Map data,
  ) async {
    try {
      final headers = _getHeaders();
      final body = jsonEncode(data);
      _logRequest('PATCH/PUT', linkurl, headers, body);
      var response = await http.put(
        Uri.parse(linkurl),
        headers: headers,
        body: body,
      );
      _logResponse(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Map responsebody = jsonDecode(response.body);
        return Right(responsebody);
      } else if (_checkUnauthorized(response)) {
        return const Left(StatusRequest.serverfailure);
      } else {
        return const Left(StatusRequest.serverfailure);
      }
    } catch (e) {
      print('🔴 [API ERROR] $e');
      return const Left(StatusRequest.offlinefailure);
    }
  }

  Future<Either<StatusRequest, Map>> getData(String linkurl) async {
    try {
      final headers = _getHeaders();
      _logRequest('GET', linkurl, headers);
      var response = await http.get(
        Uri.parse(linkurl),
        headers: headers,
      );
      _logResponse(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Map responsebody = jsonDecode(response.body);
        return Right(responsebody);
      } else if (_checkUnauthorized(response)) {
        return const Left(StatusRequest.serverfailure);
      } else {
        return const Left(StatusRequest.serverfailure);
      }
    } catch (e) {
      print('🔴 [API ERROR] $e');
      return const Left(StatusRequest.offlinefailure);
    }
  }

  Future<Either<StatusRequest, Map>> deleteData(String linkurl) async {
    try {
      final headers = _getHeaders();
      _logRequest('DELETE', linkurl, headers);
      var response = await http.delete(
        Uri.parse(linkurl),
        headers: headers,
      );
      _logResponse(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Map responsebody = jsonDecode(response.body);
        return Right(responsebody);
      } else if (_checkUnauthorized(response)) {
        return const Left(StatusRequest.serverfailure);
      } else {
        return const Left(StatusRequest.serverfailure);
      }
    } catch (e) {
      print('🔴 [API ERROR] $e');
      return const Left(StatusRequest.offlinefailure);
    }
  }
}