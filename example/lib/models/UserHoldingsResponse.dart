
import 'package:scgateway_flutter_plugin_example/models/HoldingsDataWrapper.dart';

class UserHoldingsResponse {

  final int statusCode;

  final HoldingsDataWrapper data;

  UserHoldingsResponse({
    this.statusCode,
    this.data
});

  factory UserHoldingsResponse.fromJson(Map<String, dynamic> parsedJson) {

    var dataJson = HoldingsDataWrapper.fromJson(parsedJson['data']);
    var status = parsedJson['statusCode'];

    return UserHoldingsResponse(
      statusCode: status,
      data: dataJson
    );
  }
}