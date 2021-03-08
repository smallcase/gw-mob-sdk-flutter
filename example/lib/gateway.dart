import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:scgateway_flutter_plugin/scgateway_flutter_plugin.dart';

class Gateway {

  static var _userId = "";

  static var _baseUrl = "";

  static var transactionId = "";

  static Future<String> setGatewayEnvironment(String baseUrl, String idText, GatewayEnvironment env, bool leprechaun, bool amo) async {

    _userId = idText;

    _baseUrl = baseUrl;

    final http.Response response = await http.post(
      baseUrl + 'user/login',

      headers: <String, String>{
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, GET, OPTIONS, PUT',
        'Accept': 'application/json',
        'content-type': 'application/x-www-form-urlencoded'
      },

      body: jsonEncode(<String, String>{
        'id': idText,
      }),
    );

    print("init response = " + response.body);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      var token = data["smallcaseAuthToken"] as String;

      // ScgatewayFlutterPlugin.initGateway(env, "gatewaydemo", idText, leprechaun, amo, token);

      ScgatewayFlutterPlugin.initGateway(token);

      return response.body;

    } else {
      throw Exception('Failed to get session token.');
    }
  }

  static Future<String> getTransactionId(String intent, Object orderConfig) async {
    Map data = {
      'id': _userId,
      'intent': intent,
      'orderConfig': orderConfig
    };

    String bodyData = json.encode(data);

    print(bodyData);

    final http.Response response = await http.post(
      _baseUrl + 'transaction/new',

      headers: <String, String>{
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, GET, OPTIONS, PUT',
        'Accept': 'application/json',
        'content-type':'application/json'
      },

      body: bodyData,
    );

    if (response.statusCode == 200) {
      var connectData = jsonDecode(response.body);

      var txnId = connectData["transactionId"] as String;

      print("data: " + connectData.toString());

      transactionId = txnId;

      return ScgatewayFlutterPlugin.triggerGatewayTransaction(txnId);

    } else {
      print(response.body);
      throw Exception('Failed to get session token');
    }
  }


  static Future<void> leadGen(String name, String email, String contact, String pincode) async {

    ScgatewayFlutterPlugin.leadGen(name, email, contact, pincode);

  }

  static Future<String> getAllSmallcases() async {

    // var result = ScgatewayFlutterPlugin.getAllSmallcases();

    return ScgatewayFlutterPlugin.getAllSmallcases();

  }

  static Future<String> getAllUserInvestments() async {

    return ScgatewayFlutterPlugin.getAllUserInvestments();

  }

  static Future<String> getAllExitedSmallcases() async {

    return ScgatewayFlutterPlugin.getAllExitedSmallcases();

  }

  static Future<String> getSmallcaseNews(String scid) async {

    return ScgatewayFlutterPlugin.getSmallcaseNews(scid);

  }
}