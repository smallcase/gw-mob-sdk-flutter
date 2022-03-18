
import 'package:scgateway_flutter_plugin_example/models/Securities.dart';
import 'package:scgateway_flutter_plugin_example/models/Smallcases.dart';

class HoldingsData {

  final String lastUpdate;

  final Securities securities;

  final Smallcases smallcases;

  final String snapshotDate;

  final bool updating;

  HoldingsData({
    this.lastUpdate,
    this.securities,
    this.smallcases,
    this.snapshotDate,
    this.updating
});

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
      updating: updating
    );
  }

}