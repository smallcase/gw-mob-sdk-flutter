import 'package:http/http.dart' as http;
import 'gateway.dart';

class SmartInvesting {
  final String baseUrl;
  const SmartInvesting.dev() : baseUrl = "https://api.dev.smartinvesting.io/";
  const SmartInvesting.staging()
      : baseUrl = "https://api.stag.smartinvesting.io/";
  const SmartInvesting.prod() : baseUrl = "https://api.smartinvesting.io/";

  factory SmartInvesting.fromEnvironment(Environment environment) {
    switch (environment) {
      case Environment.dev():
        return SmartInvesting.dev();
      case Environment.staging():
        return SmartInvesting.staging();
      default:
        return SmartInvesting.prod();
    }
  }

  Future<String> getUserHoldings(String userId, int version,{bool mfEnabled = false}) async {
    var url =
        Uri.parse(baseUrl + 'holdings/fetch' + '?id=$userId&version=v$version&mfHoldings=$mfEnabled');

    final http.Response response = await http.get(
      url,
      headers: <String, String>{
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, GET, OPTIONS, PUT',
        'Accept': 'application/json',
        'content-type': 'application/json'
      },
    );

    if (response.statusCode == 200) {
      print("getUserHoldings: ${response.body}");
      return response.body;
    } else {
      print("response status code: ${response.statusCode}");
      print(response.body);
      throw Exception('Failed to get user holdings');
    }
  }
}
