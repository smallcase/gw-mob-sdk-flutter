
import 'dart:ffi';

class Stats {

  final double totalReturns;

  final double currentValue;

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