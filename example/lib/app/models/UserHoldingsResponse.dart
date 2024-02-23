import 'dart:convert';

import 'package:scgateway_flutter_plugin_example/app/models/HoldingsDataWrapper.dart';

class UserHoldingsResponse {
  final int? statusCode;

  final HoldingsDataWrapper? data;

  UserHoldingsResponse({this.statusCode, this.data});

  factory UserHoldingsResponse.fromJson(Map<String, dynamic> parsedJson) {
    var dataJson = HoldingsDataWrapper.fromJson(parsedJson['data']);
    var status = parsedJson['statusCode'];

    return UserHoldingsResponse(statusCode: status, data: dataJson);
  }

  factory UserHoldingsResponse.fromMapV2(Map<String, dynamic> map) {
    return UserHoldingsResponse(
        statusCode: map['statusCode'],
        data: HoldingsDataWrapper.fromMapV2(map['data']));
  }

  factory UserHoldingsResponse.fromJsonV2(String str) =>
      UserHoldingsResponse.fromMapV2(json.decode(str));

  @override
  String toString() => 'UserHoldingsResponse(statusCode: $statusCode, data: $data)';
}
