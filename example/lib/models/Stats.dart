
import 'dart:ffi';

class Stats {

  final double totalReturns;

  final double currentValue;

  Stats({
    this.totalReturns,
    this.currentValue
});

  factory Stats.fromJson(Map<String, dynamic> parsedJson) {

    var totalReturns = double.tryParse(parsedJson['totalReturns'].toString());
    var currentValue = double.tryParse(parsedJson['currentValue'].toString());

    return Stats(
      totalReturns: totalReturns,
      currentValue: currentValue
    );

  }
}