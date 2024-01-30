import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:scgateway_flutter_plugin/scgateway_flutter_plugin.dart';
import 'app/global/SIConfigs.dart';

final _headers = <String, String>{
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, GET, OPTIONS, PUT',
  'Accept': 'application/json',
  'content-type': 'application/json'
};

class SmartInvesting {
  final String baseUrl;

  const SmartInvesting.dev() : baseUrl = "https://api.dev.smartinvesting.io/";

  const SmartInvesting.staging()
      : baseUrl = "https://api-stag.smartinvesting.io/";

  const SmartInvesting.prod() : baseUrl = "https://api.smartinvesting.io/";

  factory SmartInvesting.fromEnvironment(ScGatewayConfig environment) {
    switch (environment.environment) {
      case GatewayEnvironment.DEVELOPMENT:
        return SmartInvesting.dev();
      case GatewayEnvironment.STAGING:
        return SmartInvesting.staging();
      default:
        return SmartInvesting.prod();
    }
  }

  Future<Map<String, dynamic>> _postData(String endpoint, Map<String, dynamic> data) async {
  String bodyData = json.encode(data);
  final Dio dio = Dio();
  try {
    Response response = await dio.post(
      baseUrl + endpoint,
      data: bodyData,
      options: Options(
        headers: _headers,
      ),
    );
    if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
      return response.data;
    } else {
      print("Response status code: ${response.statusCode}");
      print(response.data);
      throw Exception('Error occurred');
    }
  } catch (e) {
    print("Error: $e");
    throw Exception('Error occurred');
  }
}

/*
    Future<Map<String, dynamic>> _postData(String endpoint, Map<String, dynamic> data) async {
    String bodyData = json.encode(data);
    
    var url = Uri.parse(baseUrl + endpoint);
    final http.Response response = await http.post(
      url,
      headers: _headers,
      body: bodyData,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      print("Response status code: ${response.statusCode}");
      print(response.body);
      throw Exception('Error occurred');
    }
  }

  */

  Future<Map<String, dynamic>> userLogin({String? userID}) async {
    Map<String, dynamic> data = {'id': userID};
    return _postData('user/login', data);
  }

  Future<String> getTransactionId(
    String userId,
    String? intent,
    Object? orderConfig, {
    Object? assetConfig,
    String? notes,
  }) async {
    Map<String, dynamic> data = {
      'id': userId,
      'intent': intent,
      'orderConfig': orderConfig,
      'assetConfig': assetConfig,
      'notes': notes,
    };
    var responseData = await _postData('transaction/new', data);
    return responseData["transactionId"] as String;
  }

  Future<List<String>> stockSearch(String query) async {
    var response = await http.get(Uri.parse(baseUrl + 'search?text=$query'));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      var result = json.decode(response.body);
       List<String> searchResults = (result['results'] as List)
      .map((result) => result['sid'] as String)
      .toList();
      return searchResults;
    } else {
      print('Failed to load search results');
      return [""];
    }
  }

  Future<String> getPostBackStatus(String transactionId) async {
    var url = Uri.parse(
        baseUrl + 'transaction/response' + '?transactionId=$transactionId');
    final http.Response response = await http.get(
      url,
      headers: _headers,
    );
    if (response.statusCode == 200) {
      print("getPostBackStatus: ${response.body}");
      return response.body;
    } else {
      print("response status code: ${response.statusCode}");
      print(response.body);
      throw Exception('Failed to get user holdings');
    }
  }

  Future<String> getUserHoldings(String userId, int version,
      {bool mfEnabled = false}) async {
    var url = Uri.parse(baseUrl +
        'holdings/fetch' +
        '?id=$userId&version=v$version&mfHoldings=$mfEnabled');
    final http.Response response = await http.get(
      url,
      headers: _headers,
    );

    if (response.statusCode == 200) {
      print("getUserHoldings: ${response.body}");
      return response.body;
    } else {
      print("response status code: ${response.statusCode}");
      print(response.body);
      throw Exception('Failed to get user holdings');
    }
  }

  @override
  String toString() {
    return "SmartInvesting(baseUrl: $baseUrl)";
  }
}
