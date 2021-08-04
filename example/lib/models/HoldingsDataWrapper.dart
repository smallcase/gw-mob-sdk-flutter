
class HoldingsDataWrapper {

  final bool success;

  final String error;

  //TODO: change dynamic to relevant type
  final dynamic data;

  final String snapshotDate;

  final bool updating;

  HoldingsDataWrapper({
    this.success,
    this.error,
    this.data,
    this.snapshotDate,
    this.updating
  });

  factory HoldingsDataWrapper.fromJson(Map<String, dynamic> parsedJson) {

    var success = parsedJson['success'];
    var error = parsedJson['error'];
    var data = parsedJson['data'];
    var snapshotDate = parsedJson['snapshotDate'];
    var updating = parsedJson['updating'];

    return HoldingsDataWrapper(
        success: success,
        error: error,
        data: data,
        snapshotDate: snapshotDate,
        updating: updating
    );
  }
}