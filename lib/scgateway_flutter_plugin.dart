import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/services.dart';
import './color_ext.dart';

enum GatewayEnvironment { PRODUCTION, DEVELOPMENT, STAGING }

class ScgatewayIntent {
  static const CONNECT = "CONNECT";
  static const TRANSACTION = "TRANSACTION";
  static const HOLDINGS = "HOLDINGS_IMPORT";
  static const AUTHORISE_HOLDINGS = "AUTHORISE_HOLDINGS";
  static const FETCH_FUNDS = "FETCH_FUNDS";
  static const SIP_SETUP = "SIP_SETUP";
  static const CANCEL_AMO = "CANCEL_AMO";
  static const MF_HOLDINGS_IMPORT = "MF_HOLDINGS_IMPORT";
}

class SmallplugData {
  String? targetEndpoint;
  String? params;
}

class SmallplugUiConfig {
  final Color? headerColor;

  final double headerOpacity;

  final Color? backIconColor;

  final double backIconOpacity;

  const SmallplugUiConfig(
      {this.headerColor,
      this.headerOpacity = 1,
      this.backIconColor,
      this.backIconOpacity = 1});

  Map<String, dynamic> toMap() => {
        "headerColor": headerColor?.toHex(
            leadingHashSign: Platform.isAndroid ? true : false),
        "headerOpacity": headerOpacity,
        "backIconColor": backIconColor?.toHex(
            leadingHashSign: Platform.isAndroid ? true : false),
        "backIconOpacity": backIconOpacity
      };
}

class ScgatewayFlutterPlugin {
  static const MethodChannel _channel =
      const MethodChannel('scgateway_flutter_plugin');

  static const String _flutterPluginVersion = "2.2.1";

  static Future<String?> getSdkVersion() async {
    String? sdkVersion;

    try {
      sdkVersion = await _channel.invokeMethod('getSdkVersion',
          <String, dynamic>{"flutterSdkVersion": _flutterPluginVersion});
    } on PlatformException catch (e) {
      print(e);
    }

    return sdkVersion;
  }

  static Future<String> setConfigEnvironment(
      GatewayEnvironment environmentSelected,
      String gateway,
      bool leprechaunMode,
      List<String> brokers,
      {bool isAmoenabled = true}) async {
    Object? setConfigResult;

    try {
      var setFlutterSdkVersion = await _channel.invokeMethod(
          'setFlutterSdkVersion',
          <String, dynamic>{"flutterSdkVersion": _flutterPluginVersion});
    } on PlatformException catch (e) {
      print(e.stacktrace);
    }

    try {
      setConfigResult =
          await _channel.invokeMethod('setConfigEnvironment', <String, dynamic>{
        "env": environmentSelected.toString(),
        "gateway": gateway,
        "leprechaun": leprechaunMode,
        "brokers": brokers,
        "amo": isAmoenabled
      });
    } on PlatformException catch (e) {
      setConfigResult = e.code;
    }

    return setConfigResult.toString();
  }

  static Future<String?> initGateway(String authToken) async {
    String? initGatewayResult;

    try {
      initGatewayResult = await _channel.invokeMethod(
          'initializeGateway', <String, dynamic>{"authToken": authToken});
      print(initGatewayResult);
    } on PlatformException catch (e) {
      initGatewayResult = e.code;
    }

    print("Init response: $initGatewayResult");

    return initGatewayResult;
  }

  static Future<String?> triggerGatewayTransaction(String txnId) async {
    String? triggerTxnRes;

    try {
      triggerTxnRes = await _channel.invokeMethod(
          'triggerTransaction', <String, dynamic>{"transactionId": txnId});
    } on PlatformException catch (e) {
      triggerTxnRes = e.code;
    }

    print("transaction res: " + triggerTxnRes!);

    return triggerTxnRes;
  }

  static Future<String?> triggerMfGatewayTransaction(String txnId) async {
    String? triggerTxnRes;

    try {
      triggerTxnRes = await _channel.invokeMethod(
          'triggerMfTransaction', <String, dynamic>{"transactionId": txnId});
    } on PlatformException catch (e) {
      triggerTxnRes = e.code;
    }

    print("transaction res: " + triggerTxnRes!);

    return triggerTxnRes;
  }

  static void leadGen(
      String name, String email, String contact, String pincode) async {
    String? leadGenRes;

    try {
      leadGenRes = await _channel.invokeMethod('leadGen', <String, dynamic>{
        "name": name,
        "email": email,
        "contact": contact,
        "pincode": pincode
      });
    } on PlatformException catch (e) {
      leadGenRes = e.code;
    }

    print(leadGenRes);
  }

  static Future<String?> leadGenWithStatus(
      String name, String email, String contact) async {
    String? leadGenRes;

    try {
      leadGenRes = await _channel.invokeMethod('leadGenWithStatus',
          <String, dynamic>{"name": name, "email": email, "contact": contact});
    } on PlatformException catch (e) {
      leadGenRes = e.code;
    }

    print(leadGenRes);
    return leadGenRes;
  }

  static Future<String?> triggerLeadGenWithLoginCta(
      String name, String email, String contact,
      {Map<String, String>? utmParams, bool? showLoginCta}) async {
    String? leadGenRes;

    try {
      print("ctad showLoginCta: $showLoginCta");
      leadGenRes =
          await _channel.invokeMethod('triggerLeadGenWithLoginCta', <String, dynamic>{
        "name": name,
        "email": email,
        "contact": contact,
        "utmParams": utmParams ?? <String, String>{},
        "showLoginCta": showLoginCta
      });
    } on PlatformException catch (e) {
      leadGenRes = e.code;
    }

    print(leadGenRes);
    return leadGenRes;
  }

  static Future<String?> getAllSmallcases() async {
    String? fetchSmallcasesRes;

    try {
      fetchSmallcasesRes =
          await _channel.invokeMethod('getAllSmallcases', null);
    } on PlatformException catch (e) {
      fetchSmallcasesRes = e.code;
    }

    // print("Flutter: allSmallcases: $fetchSmallcasesRes");

    return fetchSmallcasesRes;
  }

  static Future<String?> getAllUserInvestments() async {
    String? fetchUserInvestmentsRes;

    try {
      fetchUserInvestmentsRes =
          await _channel.invokeMethod("getUserInvestments", null);
    } on PlatformException catch (e) {
      fetchUserInvestmentsRes = e.code;
    }

    // print("user investments: $fetchUserInvestmentsRes");

    return fetchUserInvestmentsRes;
  }

  static Future<String?> getAllExitedSmallcases() async {
    String? fetchExitedSmallcases;

    try {
      fetchExitedSmallcases =
          await _channel.invokeMethod("getExitedSmallcases", null);
    } on PlatformException catch (e) {
      fetchExitedSmallcases = e.code;
    }

    print("Exited Smallcases: $fetchExitedSmallcases");

    return fetchExitedSmallcases;
  }

  static Future<String?> getSmallcaseNews(String scid) async {
    String? smallcaseNews;

    try {
      smallcaseNews = await _channel
          .invokeMethod('getSmallcaseNews', <String, dynamic>{"scid": scid});
    } on PlatformException catch (e) {
      smallcaseNews = e.code;
    }

    print("Smallcase News: $smallcaseNews");

    return smallcaseNews;
  }

  static Future<String?> markSmallcaseArchive(String iscid) async {
    String? archiveResponse;

    try {
      archiveResponse = await _channel
          .invokeMethod("markArchive", <String, dynamic>{"iscid": iscid});
    } on PlatformException catch (e) {
      archiveResponse = e.code;
    }

    print("Investment archive response: $archiveResponse");

    return archiveResponse;
  }

  static Future<String?> logoutUser() async {
    String? logoutResponse;

    try {
      logoutResponse = await _channel.invokeMethod("logoutUser", null);
    } on PlatformException catch (e) {
      logoutResponse = e.code;
    }

    print("Logout user response: $logoutResponse");

    return logoutResponse;
  }

  static Future<String?> launchSmallplug(SmallplugData smallplugData) async {
    String? smallplugResponse;

    try {
      smallplugResponse = await _channel.invokeMethod(
          "launchSmallplug", <String, dynamic>{
        "targetEndpoint": smallplugData.targetEndpoint,
        "params": smallplugData.params
      });
    } on PlatformException catch (e) {
      smallplugResponse = e.code;
    }

    print("Smallplug response: $smallplugResponse");

    return smallplugResponse;
  }

  static Future<String?> launchSmallplugWithBranding(
      SmallplugData smallplugData,
      {SmallplugUiConfig? smallplugUiConfig}) async {
    String? smallplugResponse;

    try {
      final args = <String, dynamic>{
        "targetEndpoint": smallplugData.targetEndpoint,
        "params": smallplugData.params,
      }..addAll(smallplugUiConfig?.toMap() ?? {});
      smallplugResponse =
          await _channel.invokeMethod("launchSmallplugWithBranding", args);
    } on PlatformException catch (e) {
      smallplugResponse = e.code;
    }

    print("Smallplug response: $smallplugResponse");

    return smallplugResponse;
  }

  static Future<String?> showOrders() async {
    String? showOrdersResponse;

    try {
      showOrdersResponse = await _channel.invokeMethod("showOrders");
    } on PlatformException catch (e) {
      showOrdersResponse = e.code;
    }

    print('show orders response: $showOrdersResponse');

    return showOrdersResponse;
  }
}
