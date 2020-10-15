
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';

class ScgatewayFlutterPlugin {

  static var _userId = "";

  static var _baseUrl = "";

  static var _transactionId = "";

  static const MethodChannel _channel =
      const MethodChannel('scgateway_flutter_plugin');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<String> setGatewayEnvironment(String baseUrl, String idText, int env, bool leprechaun, bool amo) async {

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

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      var connected = data["connected"] as bool;
      var token = data["smallcaseAuthToken"] as String;

      _initGateway(env, "gatewaydemo", idText, leprechaun, amo, token);

      return response.body;

    } else {
      throw Exception('Failed to get session token.');
    }
  }

  static Future<void> _initGateway(int environmentSelected, String gateway, String idText, bool leprechaunMode, bool isAmoenabled, String authToken) async {
    String initGatewayResult;

    try{
      initGatewayResult = await _channel.invokeMethod(
          'initializeGateway',
          <String, dynamic>{"env": environmentSelected, "gateway": gateway, "userId": idText, "leprechaun": leprechaunMode, "amo": isAmoenabled, "authToken": authToken});
      print(initGatewayResult);
    } on PlatformException catch (e) {
      initGatewayResult = "Failed to get result: ' ${e.message}'";
    }
  }

  static Future<void> getTransactionId(String gatewayIntent, Object orderConfig) async {

    String connectGatewayResult;

    try {
      connectGatewayResult = await _channel.invokeMethod(
          'getTransactionId', <String, dynamic>{"intent": gatewayIntent}
      );
      print(connectGatewayResult);
    } on PlatformException catch (e) {
      connectGatewayResult = "Failed to get result: ' ${e.message}'";
    }

    Map data = {
      'id': _userId,
      'intent': connectGatewayResult,
      'orderConfig': null
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

    print(response.body);

    if (response.statusCode == 200) {
      var connectData = jsonDecode(response.body);

      var txnId = connectData["transactionId"] as String;

      _transactionId = txnId;

      _triggerGatewayTransaction(txnId);

    } else {
      throw Exception('Failed to get session token.');
    }
  }

  static Future<void> _triggerGatewayTransaction(String txnId) async{

    String triggerTxnRes;

    try {
      triggerTxnRes = await _channel.invokeMethod(
          'connectToBroker', <String, dynamic>{"transactionId": txnId}
      );

      // print(triggerTxnRes);

      if(!triggerTxnRes.contains("error")) {
        _onUserConnected(triggerTxnRes);
      }

    } on PlatformException catch (e) {
      triggerTxnRes = "Failed to get result: ' ${e.message}'";
    }

  }

  static Future<void> _onUserConnected(String smallcaseAuthToken) async {

    Map data = {
      'id': _userId,
      'smallcaseAuthToken': smallcaseAuthToken
    };

    String bodyData = json.encode(data);

    final http.Response response = await http.post(
      _baseUrl + 'user/connect',

      headers: <String, String>{
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, GET, OPTIONS, PUT',
        'Accept': 'application/json',
        'content-type':'application/json'
      },

      body: bodyData
    );

    print(response.body);
  }
}
