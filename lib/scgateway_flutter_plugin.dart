
import 'dart:async';
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

  static const MethodChannel _channel = const MethodChannel('scgateway_flutter_plugin');

  static Future<String> setConfigEnvironment(GatewayEnvironment environmentSelected, String gateway, bool leprechaunMode, List<String> brokers, {bool isAmoenabled = true}) async {

    Object setConfigResult;

    try{
      setConfigResult = await _channel.invokeMethod(
          'setConfigEnvironment',
          <String, dynamic>{"env": environmentSelected.toString(), "gateway": gateway, "leprechaun": leprechaunMode, "brokers": brokers, "amo": isAmoenabled});
    } on PlatformException catch (e) {
      setConfigResult = e.code;
    }

    return setConfigResult.toString();

  }

  static Future<String> initGateway(String authToken) async {

    String initGatewayResult;

    try{
      initGatewayResult = await _channel.invokeMethod(
          'initializeGateway',
          <String, dynamic>{"authToken": authToken});
      print(initGatewayResult);
    } on PlatformException catch (e) {
      initGatewayResult = e.code;
    }

    print("Init response: $initGatewayResult");

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

    print("transaction res: " + triggerTxnRes);

    return triggerTxnRes;

  }

  static void leadGen(String name, String email, String contact, String pincode) async {

    String leadGenRes;

    try{
      leadGenRes = await _channel.invokeMethod(
          'leadGen',
          <String, dynamic>{"name": name, "email": email, "contact": contact, "pincode": pincode});
    } on PlatformException catch (e) {
      leadGenRes = e.code;
    }

    print(leadGenRes);

  }

  static Future<String> getAllSmallcases() async {

    String fetchSmallcasesRes;

    try{
      fetchSmallcasesRes = await _channel.invokeMethod(
          'getAllSmallcases',
        null
      );
    } on PlatformException catch (e) {
      fetchSmallcasesRes = e.code;
    }

    // print("Flutter: allSmallcases: $fetchSmallcasesRes");

    return fetchSmallcasesRes;
  }

  static Future<String> getAllUserInvestments() async {

    String fetchUserInvestmentsRes;

    try {
      fetchUserInvestmentsRes = await _channel.invokeMethod(
        "getUserInvestments",
        null
      );
    } on PlatformException catch (e) {
      fetchUserInvestmentsRes = e.code;
    }

    // print("user investments: $fetchUserInvestmentsRes");

    return fetchUserInvestmentsRes;

  }

  static Future<String> getAllExitedSmallcases() async {

    String fetchExitedSmallcases;

    try {
      fetchExitedSmallcases = await _channel.invokeMethod(
          "getExitedSmallcases",
          null
      );
    } on PlatformException catch (e) {
      fetchExitedSmallcases = e.code;
    }

    print("Exited Smallcases: $fetchExitedSmallcases");

    return fetchExitedSmallcases;
  }

  static Future<String> getSmallcaseNews(String scid) async {

    String smallcaseNews;

    try{
      smallcaseNews = await _channel.invokeMethod(
          'getSmallcaseNews',
          <String, dynamic>{"scid": scid}
          );
    } on PlatformException catch (e) {
      smallcaseNews = e.code;
    }

    print("Smallcase News: $smallcaseNews");

    return smallcaseNews;
  }

  static Future<String> markSmallcaseArchive(String iscid) async {

    String archiveResponse;

    try {
      archiveResponse = await _channel.invokeMethod(
          "markArchive",
          <String, dynamic>{"iscid": iscid}
      );
    } on PlatformException catch (e) {
      archiveResponse = e.code;
    }

    print("Investment archive response: $archiveResponse");

    return archiveResponse;
  }

  static Future<String> logoutUser() async {

    String logoutResponse;

    try {
      logoutResponse = await _channel.invokeMethod("logoutUser", null);
    } on PlatformException catch (e) {
      logoutResponse = e.code;
    }

    print("Logout user reponse: $logoutResponse");

    return logoutResponse;
  }

  static Future<String> launchSmallplug() async {

    String smallplugResponse;

    try {
      smallplugResponse = await _channel.invokeMethod("launchSmallplug", null);
    } on PlatformException catch (e) {
      smallplugResponse = e.code;
    }

    print("Smallplug response: $smallplugResponse");

    return smallplugResponse;
  }

}
