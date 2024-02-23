import 'package:scgateway_flutter_plugin_example/app/models/Holding.dart';

class Securities {
  final List<Holding>? holdings;

  Securities({this.holdings});

  factory Securities.fromJson(Map<String, dynamic> parsedJson) {
    var holdingsJson = parsedJson['holdings'] as List;
    List<Holding> holdings =
        holdingsJson.map((e) => Holding.fromJson(e)).toList();

    return Securities(holdings: holdings);
  }
}

abstract class SecuritiesI {
  String? get ticker;
  dynamic get averagePrice;
  int? get shares;
}

class SecurityV2 implements SecuritiesI {
  Holding? holdings;
  Positions? positions;
  int? transactableQuantity;
  int? smallcaseQuantity;
  String? nseTicker;
  String? bseTicker;
  String? isin;
  String? name;

  @override
  get averagePrice => holdings?.averagePrice;

  @override
  int get shares => holdings?.shares ?? transactableQuantity ?? 0;

  @override
  String get ticker => name ?? "";

  SecurityV2({
     this.holdings,
     this.positions,
     this.transactableQuantity,
     this.smallcaseQuantity,
     this.nseTicker,
     this.bseTicker,
     this.isin,
     this.name,
  });

  factory SecurityV2.fromMap(Map<String, dynamic> map) => SecurityV2(
      holdings: Holding.fromJson(map['holdings']),
      positions: Positions.fromMap(map['positions']),
      transactableQuantity: map['transactableQuantity'],
      smallcaseQuantity: map['smallcaseQuantity'],
      nseTicker: map['nseTicker'],
      bseTicker: map['bseTicker'],
      isin: map['isin'],
      name: map['name']);

  @override
  String toString() {
    return 'SecurityV2(holdings: $holdings, positions: $positions, transactableQuantity: $transactableQuantity, smallcaseQuantity: $smallcaseQuantity, nseTicker: $nseTicker, bseTicker: $bseTicker, isin: $isin, name: $name)';
  }
}

class Positions {
  Holding? nse;
  Holding? bse;
  Positions({
     this.nse,
     this.bse,
  });

  factory Positions.fromMap(Map<String, dynamic> map) => Positions(
      nse: Holding.fromJson(map['nse']), bse: Holding.fromJson(map['bse']));
}
