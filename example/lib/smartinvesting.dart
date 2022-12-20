import 'dart:convert';

import 'package:http/http.dart' as http;
import 'gateway.dart';

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
      : baseUrl = "https://api.stag.smartinvesting.io/";

  const SmartInvesting.prod() : baseUrl = "https://api.smartinvesting.io/";

  factory SmartInvesting.fromEnvironment(Environment environment) {
    switch (environment.envIndex) {
      case 1:
        return SmartInvesting.dev();
      case 2:
        return SmartInvesting.staging();
      default:
        return SmartInvesting.prod();
    }
  }

  Future<String> getTransactionId(
      String userId, String intent, Object orderConfig,
      {Object assetConfig, String notes}) async {
    Map data = {
      'id': userId,
      'intent': intent,
      'orderConfig': orderConfig,
      'assetConfig': assetConfig,
      'notes': notes
    };

    String bodyData = json.encode(data);
    print("requestBody = $bodyData");
    var url = Uri.parse(baseUrl + 'transaction/new');
    print("getTransactionId url : ${url}");

    final http.Response response = await http.post(
      url,
      headers: _headers,
      body: bodyData,
    );

    if (response.statusCode == 200) {
      var connectData = jsonDecode(response.body);
      var txnId = connectData["transactionId"] as String;
      print("data: " + connectData.toString());
      return txnId;
    } else {
      print("response status code: ${response.statusCode}");
      print(response.body);
      throw Exception('Failed to get transactionId');
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
