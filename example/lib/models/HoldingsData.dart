
class HoldingsData {

  final String lastUpdate;

  //TODO: change dynamic
  final dynamic securities;

  //TODO: change dynamic
  final dynamic smallcases;

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
    var securities = parsedJson['securities'];
    var smallcases = parsedJson['smallcases'];
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