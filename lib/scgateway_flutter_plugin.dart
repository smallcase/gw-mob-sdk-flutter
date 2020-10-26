
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';

 enum GatewayEnvironment {
  PRODUCTION,
  DEVELOPMENT,
  STAGING
}

class ScgatewayIntent {
     static const CONNECT = "CONNECT";
     static const TRANSACTION = "TRANSACTION";
     static const HOLDINGS = "HOLDINGS_IMPORT";
     static const AUTHORISE_HOLDINGS = "AUTHORISE_HOLDINGS";
     static const FETCH_FUNDS = "FETCH_FUNDS";
     static const SIP_SETUP = "SIP_SETUP";
}

class ScgatewayFlutterPlugin {

  static const MethodChannel _channel =
      const MethodChannel('scgateway_flutter_plugin');

  static Future<String> setConfigEnvironment(GatewayEnvironment environmentSelected, String gateway, String idText, bool leprechaunMode, {bool isAmoenabled = true}) async {

    Object setConfigResult;

    try{
      setConfigResult = await _channel.invokeMethod(
          'setConfigEnvironment',
          <String, dynamic>{"env": environmentSelected.toString(), "gateway": gateway, "userId": idText, "leprechaun": leprechaunMode, "amo": isAmoenabled});

    } on PlatformException catch (e) {
      setConfigResult = "Failed to set config :' ${e.message}'";
    }
    return setConfigResult;

  }

  static Future<String> initGateway(String authToken) async {

    String initGatewayResult;

    try{
      initGatewayResult = await _channel.invokeMethod(
          'initializeGateway',
          <String, dynamic>{"authToken": authToken});
      print(initGatewayResult);
    } on PlatformException catch (e) {
      initGatewayResult = "Failed to get result: ' ${e.message}'";
    }

    return initGatewayResult;
  }


  static Future<String> triggerGatewayTransaction(String txnId) async{

    String triggerTxnRes;

    try {
      triggerTxnRes = await _channel.invokeMethod(
          'triggerTransaction', <String, dynamic>{"transactionId": txnId}
      );
    } on PlatformException catch (e) {
      triggerTxnRes = e.code;
    }
    // } on PlatformException catch (e) {
    //   triggerTxnRes = "Failed to get result: ' ${e}'";
    // }

    print("transaction res: " + triggerTxnRes);

    return triggerTxnRes;

  }

  static void leadGen(String name, String email, String contact, String pincode) async {

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
