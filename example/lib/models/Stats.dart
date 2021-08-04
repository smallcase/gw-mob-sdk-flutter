
class Stats {

  final dynamic totalReturns;

  final dynamic currentValue;

  Stats({
    this.totalReturns,
    this.currentValue
});

  factory Stats.fromJson(Map<String, dynamic> parsedJson) {

    var totalReturns = parsedJson['totalReturns'];
    var currentValue = parsedJson['currentValue'];

    return Stats(
      totalReturns: totalReturns,
      currentValue: currentValue
    );

  }
}