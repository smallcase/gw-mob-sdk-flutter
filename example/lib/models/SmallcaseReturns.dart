
import 'dart:ffi';

class SmallcaseReturns {

  final double daily;

  final double weekly;

  final double monthly;

  final double yearly;

  SmallcaseReturns({this.daily, this.weekly, this.monthly, this.yearly});

  factory SmallcaseReturns.fromJson(Map<String, dynamic> parsedJson) {

    return SmallcaseReturns(
      daily: parsedJson['daily'],
      weekly: parsedJson['weekly'],
      monthly: parsedJson['monthly'],
      yearly: parsedJson['yearly'],
    );

  }
}