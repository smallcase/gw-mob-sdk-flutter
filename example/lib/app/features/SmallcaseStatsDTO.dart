import 'dart:ffi';

import 'package:scgateway_flutter_plugin_example/app/features/RatiosDTO.dart';
import 'package:scgateway_flutter_plugin_example/app/features/SmallcaseReturns.dart';

class SmallcaseStatsDTO {

  final SmallcaseReturns? returns;

  final num? indexValue;

  final num? unadjustedValue;

  final dynamic divReturns;

  final num? lastCloseIndex;

  final dynamic minInvestAmount;

  final RatiosDTO? ratios;

  SmallcaseStatsDTO({
    this.returns,
    this.indexValue,
    this.unadjustedValue,
    this.divReturns,
    this.lastCloseIndex,
    this.minInvestAmount,
    this.ratios
});

  factory SmallcaseStatsDTO.fromJson(Map<String, dynamic> parsedJson) {

    return SmallcaseStatsDTO(
      returns: SmallcaseReturns.fromJson(parsedJson['returns']),
      indexValue: parsedJson['indexValue'],
      unadjustedValue: parsedJson['unadjustedValue'],
      divReturns: parsedJson['divReturns'],
      lastCloseIndex: parsedJson['lastCloseIndex'],
      minInvestAmount: parsedJson['minInvestAmount'],
      ratios: RatiosDTO.fromJson(parsedJson['ratios'])
    );

  }

}