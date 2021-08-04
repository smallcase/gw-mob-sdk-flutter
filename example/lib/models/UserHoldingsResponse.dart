
class UserHoldingsResponse {

  final int statusCode;

  //TODO: change dynamic to HoldingsDataWrapper
  final dynamic data;

  UserHoldingsResponse({
    this.statusCode,
    this.data
});

  factory UserHoldingsResponse.fromJson(Map<String, dynamic> parsedJson) {

    var dataJson = parsedJson['data'];
    var status = parsedJson['statusCode'];

    return UserHoldingsResponse(
      statusCode: status,
      data: dataJson
    );
  }
}