import 'package:scgateway_flutter_plugin_example/models/HoldingsData.dart';

class HoldingsDataWrapper {
  final bool success;

  final String error;

  final HoldingsData data;
  final HoldingsDataV2 dataV2;

  bool get isV2 => dataV2 != null;
  bool get hasMfData => isV2 ? dataV2.mutualFunds !=null : data.mutualFunds !=null;

  final String snapshotDate;

  final bool updating;

  HoldingsDataWrapper(
      {this.success,
      this.error,
      this.data,
      this.dataV2,
      this.snapshotDate,
      this.updating});

  factory HoldingsDataWrapper.fromJson(Map<String, dynamic> parsedJson) {
    var success = parsedJson['success'];
    var error = parsedJson['error'];
    var data = HoldingsData.fromJson(parsedJson['data']);
    var snapshotDate = parsedJson['snapshotDate'];
    var updating = parsedJson['updating'];

    return HoldingsDataWrapper(
        success: success,
        error: error,
        data: data,
        dataV2: null,
        snapshotDate: snapshotDate,
        updating: updating);
  }

  factory HoldingsDataWrapper.fromMapV2(Map<String, dynamic> map) =>
      HoldingsDataWrapper(
          success: map['success'],
          error: map['error'],
          data: null,
          dataV2: HoldingsDataV2.fromMap(map['data']),
          snapshotDate: map['snapshotDate'],
          updating: map['updating']);

  @override
  String toString() {
    return 'HoldingsDataWrapper(success: $success, error: $error, data: $data, dataV2: $dataV2, snapshotDate: $snapshotDate, updating: $updating)';
  }
}
