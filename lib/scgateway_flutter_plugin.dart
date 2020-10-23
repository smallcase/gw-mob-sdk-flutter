
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

  static Future<void> initGateway(int environmentSelected, String gateway, String idText, bool leprechaunMode, bool isAmoenabled, String authToken) async {
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

  static Future<String> getGatewayIntent(String intent) async {

    String gatewayIntent;

    try {
      gatewayIntent = await _channel.invokeMethod(
          'getTransactionId', <String, dynamic>{"intent": intent}
      );
      print(gatewayIntent);
    } on PlatformException catch (e) {
      gatewayIntent = "Failed to get result: ' ${e.message}'";
    }

    return gatewayIntent;
  }

  static Future<String> triggerGatewayTransaction(String txnId) async{

    String triggerTxnRes;

    try {
      triggerTxnRes = await _channel.invokeMethod(
          'connectToBroker', <String, dynamic>{"transactionId": txnId}
      );

    } on PlatformException catch (e) {
      triggerTxnRes = "Failed to get result: ' ${e.message}'";
    }

    print("transaction res: " + triggerTxnRes);

    return triggerTxnRes;

  }

  static Future<void> leadGen(String name, String email, String contact, String pincode) async {

    String leadGenRes;

    try{
      leadGenRes = await _channel.invokeMethod(
          'leadGen',
          <String, dynamic>{"name": name, "email": email, "contact": contact, "pincode": pincode});
      print(leadGenRes);
    } on PlatformException catch (e) {
      leadGenRes = "Failed to get result: ' ${e.message}'";
    }

  }
}
