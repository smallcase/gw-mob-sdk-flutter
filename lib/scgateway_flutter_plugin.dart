
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';

class ScgatewayFlutterPlugin {
  static const MethodChannel _channel =
      const MethodChannel('scgateway_flutter_plugin');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<String> setGatewayEnvironment(String baseUrl, String idText, int env, bool leprechaun, bool amo) async {
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

      _initGateway(env, "gatewaydemo", idText, leprechaun, amo, data["smallcaseAuthToken"] as String);

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
}
