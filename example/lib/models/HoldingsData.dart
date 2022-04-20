import 'package:scgateway_flutter_plugin_example/models/Securities.dart';
import 'package:scgateway_flutter_plugin_example/models/Smallcases.dart';

class HoldingsData {
  final String lastUpdate;

  final Securities securities;

  final Smallcases smallcases;

  final String snapshotDate;

  final bool updating;

  HoldingsData(
      {this.lastUpdate,
      this.securities,
      this.smallcases,
      this.snapshotDate,
      this.updating});

  factory HoldingsData.fromJson(Map<String, dynamic> parsedJson) {
    var lastUpdate = parsedJson['lastUpdate'];
    var securities = Securities.fromJson(parsedJson['securities']);
    var smallcases = Smallcases.fromJson(parsedJson['smallcases']);
    var snapshotDate = parsedJson['snapshotDate'];
    var updating = parsedJson['updating'];

    return HoldingsData(
        lastUpdate: lastUpdate,
        securities: securities,
        smallcases: smallcases,
        snapshotDate: snapshotDate,
        updating: updating);
  }
}

class HoldingsDataV2 {
  final String lastUpdate;

  final List<SecurityV2> securities;

  final SmallcasesV2 smallcases;

  final String snapshotDate;

  final bool updating;

  HoldingsDataV2(
      {this.lastUpdate,
      this.securities,
      this.smallcases,
      this.snapshotDate,
      this.updating});

  factory HoldingsDataV2.fromMap(Map<String, dynamic> map) => HoldingsDataV2(
    lastUpdate: map['lastUpdate'],
    snapshotDate: map['snapshotDate'],
    updating: map['updating'],
    securities: (map['securities'] as List)?.map((e) => SecurityV2.fromMap(e))?.toList(),
    smallcases: SmallcasesV2.fromMap(map['smallcases'])
  );

  @override
  String toString() {
    return 'HoldingsDataV2(lastUpdate: $lastUpdate, securities: $securities, smallcases: $smallcases, snapshotDate: $snapshotDate, updating: $updating)';
  }
}
