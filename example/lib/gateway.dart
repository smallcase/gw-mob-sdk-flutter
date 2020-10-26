import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:scgateway_flutter_plugin/scgateway_flutter_plugin.dart';

class Gateway {

  static var _userId = "";

  static var _baseUrl = "";

  // static var transactionId = "";

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

  // static Future<String> triggerTransaction(String intent, Object orderConfig) async {
  //
  //   String _txnID;
  //
  //   return ScgatewayFlutterPlugin.getGatewayIntent(intent)
  //       .then((value) =>
  //
  //        // _getTransactionId(value, orderConfig).then((id) => _txnID = id)
  //       getTransactionId(value, orderConfig).then((data) => _txnID = data)
  //   );
  // }

  static Future<String> getTransactionId(String intent, Object orderConfig) async {
    Map data = {
      'id': _userId,
      'intent': intent,
      'orderConfig': orderConfig
    };

    String bodyData = json.encode(data);

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

    // print(response.body);

    if (response.statusCode == 200) {
      var connectData = jsonDecode(response.body);

      var txnId = connectData["transactionId"] as String;

      print("connect data: " + connectData.toString());

      transactionId = txnId;

      // return ScgatewayFlutterPlugin.triggerGatewayTransaction(txnId).then((value) => _onUserConnected(value));

      return ScgatewayFlutterPlugin.triggerGatewayTransaction(txnId);
      // return txnId;

    } else {
      throw Exception('Failed to get session token.');
    }
  }

  // static Future<void> importHoldings() {
  //
  //   triggerTransaction("holdings",null);
  //
  // }

  static Future<void> leadGen(String name, String email, String contact, String pincode) async {

    ScgatewayFlutterPlugin.leadGen(name, email, contact, pincode);

  }
}