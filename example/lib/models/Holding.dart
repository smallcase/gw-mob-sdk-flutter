import 'dart:convert';

import 'package:scgateway_flutter_plugin_example/screens/UserHoldingsScreen.dart';

class Holding implements SecuritiesI {
  final dynamic averagePrice;

  final String name;

  final int shares;

  final String ticker;

  Holding({this.averagePrice, this.name, this.shares, this.ticker});

  factory Holding.fromJson(Map<String, dynamic> parsedJson) {
    var averagePrice = parsedJson['averagePrice'];
    var name = parsedJson['name'];
    var shares = parsedJson['shares'];
    var ticker = parsedJson['ticker'];

    return Holding(
        averagePrice: averagePrice, name: name, shares: shares, ticker: ticker);
  }
}

class MFHolding {
  String folio;
  String fund;
  String tradingsymbol;
  double pnl;
  double quantity;
  String isin;
  double averagePrice;
  String lastPriceDate;
  double lastPrice;
  double xirr;
  MFHolding({
    this.folio,
    this.fund,
    this.tradingsymbol,
    this.pnl,
    this.quantity,
    this.isin,
    this.averagePrice,
    this.lastPriceDate,
    this.lastPrice,
    this.xirr,
  });

  Map<String, dynamic> toMap() {
    return {
      'folio': folio,
      'fund': fund,
      'tradingsymbol': tradingsymbol,
      'pnl': pnl,
      'quantity': quantity,
      'isin': isin,
      'averagePrice': averagePrice,
      'lastPriceDate': lastPriceDate,
      'lastPrice': lastPrice,
      'xirr': xirr,
    };
  }

  factory MFHolding.fromMap(Map<String, dynamic> map) {
    return MFHolding(
      folio: map['folio'] ?? '',
      fund: map['fund'] ?? '',
      tradingsymbol: map['tradingsymbol'] ?? '',
      pnl: map['pnl']?.toDouble() ?? 0.0,
      quantity: map['quantity']?.toDouble() ?? 0.0,
      isin: map['isin'] ?? '',
      averagePrice: map['averagePrice']?.toDouble() ?? 0.0,
      lastPriceDate: map['lastPriceDate'],
      lastPrice: map['lastPrice']?.toDouble() ?? 0.0,
      xirr: map['xirr']?.toDouble() ?? 0.0,
    );
  }

  @override
  String toString() {
    return 'MFHolding(folio: $folio, fund: $fund, tradingsymbol: $tradingsymbol, pnl: $pnl, quantity: $quantity, isin: $isin, averagePrice: $averagePrice, lastPriceDate: $lastPriceDate, lastPrice: $lastPrice, xirr: $xirr)';
  }
}
