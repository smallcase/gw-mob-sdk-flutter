import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:scgateway_flutter_plugin/scgateway_flutter_plugin.dart';

class Gateway {

  static var userId = "";

  static var baseURL = "";

  static var transactionId = "";

  static Future<String> getSessionToken(String baseUrl, String idText, GatewayEnvironment env, bool leprechaun, bool amo) async {

    userId = idText;

    baseURL = baseUrl;

    print("userId: $userId baseUrl: $baseURL");

    // Map data = {'id': idText};
    // String bodyData = json.encode(data);
    // print(bodyData);

    // var body = jsonEncode(<String, String>{
    //   'id': idText,
    // });

    var body = {'id':userId};

    print("requestBody = $body");

    final http.Response response = await http.post(
      baseUrl + 'user/login',

      headers: <String, String>{
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, GET, OPTIONS, PUT',
        'Accept': 'application/json',
        'content-type': 'application/x-www-form-urlencoded'
      },

      // body: jsonEncode(<String, String>{
      //   'id': idText,
      // }),
      body: body
    );

    print("init response = " + response.body);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      var token = data["smallcaseAuthToken"] as String;

      // ScgatewayFlutterPlugin.initGateway(env, "gatewaydemo", idText, leprechaun, amo, token);

      // print("SmallcaseAuthToken from api response: $token");

      return ScgatewayFlutterPlugin.initGateway(token);

      // return response.body;

    } else {
      throw Exception('Failed to get session token.');
    }
  }

  static Future<String> getTransactionId(String intent, Object orderConfig) async {
    Map data = {
      'id': userId,
      'intent': intent,
      'orderConfig': orderConfig
    };

    String bodyData = json.encode(data);

    print(bodyData);

    // var bodyData = {'id':_userId, 'intent': intent};
    //
    // if(orderConfig != null) {
    //   bodyData = {'id':_userId, 'intent': intent, 'orderConfig': orderConfig};
    // }

    print("requestBody = $bodyData");

    final http.Response response = await http.post(
      baseURL + 'transaction/new',

      headers: <String, String>{
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, GET, OPTIONS, PUT',
        'Accept': 'application/json',
        'content-type':'application/json'
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

  static Future<String> markArchive(String iscid) async {

    return ScgatewayFlutterPlugin.markSmallcaseArchive(iscid);

  }

  static Future<String> logout() async {

    return ScgatewayFlutterPlugin.logoutUser();

  }
}