import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import 'package:scgateway_flutter_plugin/scgateway_flutter_plugin.dart';
import 'package:scgateway_flutter_plugin_example/models/UserHoldingsResponse.dart';
import 'package:scgateway_flutter_plugin_example/smartinvesting.dart';

extension ColorExt on Color {
  static Color fromHex(String hexString) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } on Exception catch (e) {
      return null;
    }
  }
}

class Environment {
  final String gatewayName;
  final GatewayEnvironment gatewayEnvironment;

  /// ```0: Prod, 1: Dev, 2: Staging```
  final int envIndex;
  const Environment({
    @required this.envIndex,
    this.gatewayName = "gatewaydemo",
    this.gatewayEnvironment,
  });

  const Environment.prod({
    this.gatewayName = "gatewaydemo",
  })  : this.envIndex = 0,
        this.gatewayEnvironment = GatewayEnvironment.PRODUCTION;
  const Environment.dev({
    this.gatewayName = "gatewaydemo-dev",
  })  : this.envIndex = 1,
        this.gatewayEnvironment = GatewayEnvironment.DEVELOPMENT;
  const Environment.staging({
    this.gatewayName = "gatewaydemo-stag",
  })  : this.envIndex = 2,
        this.gatewayEnvironment = GatewayEnvironment.STAGING;

  String get envName {
    switch (envIndex) {
      case 1:
        return "Dev";
      case 2:
        return "Staging";
      default:
        return "Prod";
    }
  }

  @override
  String toString() =>
      'Environment(gatewayName: $gatewayName, gatewayEnvironment: $gatewayEnvironment, envIndex: $envIndex)';
}

class Gateway {
  static Environment env;
  static SmartInvesting smartInvesting;
  static var userId = "";

  static String get baseURL => smartInvesting?.baseUrl ?? "";

  static var transactionId = "";

  static Future<String> getSessionToken(
      Environment environment, String idText, bool leprechaun, bool amo) async {
    env = environment;
    print("getSessionToken env ${env}");
    smartInvesting = SmartInvesting.fromEnvironment(env);
    print("smart inv ${smartInvesting}");

    userId = idText;
    print("userId: $userId baseUrl: $baseURL");

    var body = {'id': userId ?? ""};
    print("requestBody = $body");

    var url = Uri.parse(baseURL + 'user/login');
    final http.Response response = await http.post(url,
        headers: <String, String>{
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'POST, GET, OPTIONS, PUT',
          'Accept': 'application/json',
          'content-type': 'application/x-www-form-urlencoded'
        },
        body: body);

    print("get session token response = " + response.body);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      var token = data["smallcaseAuthToken"] as String;

      return ScgatewayFlutterPlugin.initGateway(token);
    } else {
      throw Exception('Failed to get session token.');
    }
  }

  static Future<String> getTransactionId(
      String intent, Object orderConfig) async {
    Map data = {'id': userId, 'intent': intent, 'orderConfig': orderConfig};

    String bodyData = json.encode(data);

    // var bodyData = {'id':_userId, 'intent': intent};
    //
    // if(orderConfig != null) {
    //   bodyData = {'id':_userId, 'intent': intent, 'orderConfig': orderConfig};
    // }

    print("requestBody = $bodyData");

    var url = Uri.parse(baseURL + 'transaction/new');
    print("getTransactionId url : ${url}");

    final http.Response response = await http.post(
      url,
      headers: <String, String>{
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, GET, OPTIONS, PUT',
        'Accept': 'application/json',
        'content-type': 'application/json'
        // 'content-type': 'application/x-www-form-urlencoded'
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
      print("response status code: ${response.statusCode}");
      print(response.body);
      throw Exception('Failed to get transactionId');
    }
  }

  static Future<UserHoldingsResponse> getUserHoldings(
      {int version = 1, bool mfEnabled = false}) async {
    try {
      final response = await smartInvesting.getUserHoldings(userId, version,
          mfEnabled: mfEnabled);
      if (version == 2) {
        return UserHoldingsResponse.fromJsonV2(response);
      }
      return UserHoldingsResponse.fromJson(json.decode(response));
    } on Exception catch (e) {
      print("Gateway Exception!! getUserHoldings : $e");
      return null;
    }
  }

  static Future<String> triggerTransactionWithTransactionId(
      String txnId) async {
    return ScgatewayFlutterPlugin.triggerGatewayTransaction(txnId);
  }

  static void leadGen(
      String name, String email, String contact, String pincode) async {
    ScgatewayFlutterPlugin.leadGen(name, email, contact, pincode);
  }

  static Future<String> leadGenWithStatus(
      String name, String email, String contact) async {
    return ScgatewayFlutterPlugin.leadGenWithStatus(name, email, contact);
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

  static Future<String> markArchive(String iscid) async {

    // String resp = await ScgatewayFlutterPlugin.markSmallcaseArchive(iscid);

    return ScgatewayFlutterPlugin.markSmallcaseArchive(iscid);
  }

  static Future<String> logout() async {
    return ScgatewayFlutterPlugin.logoutUser();
  }

  static Future<String> openSmallplug(String smallplugEndpoint) async {
    SmallplugData smallplugData = new SmallplugData();

    if (smallplugEndpoint != null && smallplugEndpoint.isNotEmpty) {
      smallplugData.targetEndpoint = smallplugEndpoint;
    }

    // smallplugData.params = "test=abc";

    return ScgatewayFlutterPlugin.launchSmallplug(smallplugData);
  }

  static Future<String> openSmallplugWithBranding(
      String smallplugEndpoint,
      String params,
      String headerColor,
      double headerColorOpacity,
      String backIconColor,
      double backIconOpacity) async {
    SmallplugData smallplugData = new SmallplugData();
    final hc = headerColor == null ? null : ColorExt.fromHex(headerColor);
    final bc = headerColor == null ? null : ColorExt.fromHex(backIconColor);
    debugPrint("hc: $hc");
    SmallplugUiConfig smallplugUiConfig = new SmallplugUiConfig(
        headerColor: hc,
        backIconColor: bc,
        headerOpacity: headerColorOpacity,
        backIconOpacity: backIconOpacity);

    if (smallplugEndpoint != null && smallplugEndpoint.isNotEmpty) {
      smallplugData.targetEndpoint = smallplugEndpoint;
    }

    return ScgatewayFlutterPlugin.launchSmallplugWithBranding(smallplugData,
        smallplugUiConfig: smallplugUiConfig);
  }

  static Future<String> showOrders() async {
    return ScgatewayFlutterPlugin.showOrders();
    // return "";
  }
}
