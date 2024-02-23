import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:scgateway_flutter_plugin_example/app/models/Holding.dart';
import 'package:scgateway_flutter_plugin_example/app/models/Securities.dart';
import 'package:scgateway_flutter_plugin_example/app/models/Smallcases.dart';

class HoldingsData {
  final String? lastUpdate;
  final Securities? securities;
  final Smallcases? smallcases;
  final String? snapshotDate;
  final bool? updating;
  final MutualFunds? mutualFunds;

  HoldingsData(
      {this.lastUpdate,
      this.securities,
      this.smallcases,
      this.snapshotDate,
      this.updating,
      this.mutualFunds});

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
        updating: updating,
        mutualFunds: MutualFunds.fromMap(parsedJson['mutualFunds']));
  }
}

class HoldingsDataV2 {
  final String? lastUpdate;
  final List<SecurityV2>? securities;
  final SmallcasesV2? smallcases;
  final String? snapshotDate;
  final bool? updating;
  final MutualFunds? mutualFunds;

  HoldingsDataV2(
      {this.lastUpdate,
      this.securities,
      this.smallcases,
      this.snapshotDate,
      this.updating,
      this.mutualFunds});

  factory HoldingsDataV2.fromMap(Map<String, dynamic> map) => HoldingsDataV2(
      lastUpdate: map['lastUpdate'],
      snapshotDate: map['snapshotDate'],
      updating: map['updating'],
      securities: (map['securities'] as List)
          ?.map((e) => SecurityV2.fromMap(e))
          ?.toList(),
      smallcases: SmallcasesV2.fromMap(map['smallcases']),
      mutualFunds: MutualFunds.fromMap(map['mutualFunds']));

  @override
  String toString() {
    return 'HoldingsDataV2(lastUpdate: $lastUpdate, securities: $securities, smallcases: $smallcases, snapshotDate: $snapshotDate, updating: $updating)';
  }
}

class MutualFunds {
  final List<MFHolding>? holdings;

  MutualFunds({
    this.holdings,
  });

  Map<String, dynamic> toMap() {
    return {
      'holdings': holdings?.map((x) => x.toMap()).toList(),
    };
  }


factory MutualFunds.fromMap(Map<String, dynamic> map) {
  if (map == null) {
    // Handle the case where map is null
    return MutualFunds(holdings: null);
  } else {
    return MutualFunds(
      holdings: List<MFHolding>.from(
        map['holdings']?.map((x) => MFHolding.fromMap(x)) ?? [],
      ),
    );
  }
}

}
