
class Holding {

  final double averagePrice;

  final String name;

  final int shares;

  final String ticker;

  Holding({
    this.averagePrice,
    this.name,
    this.shares,
    this.ticker
});

  factory Holding.fromJson(Map<String, dynamic> parsedJson) {

    var averagePrice = parsedJson['averagePrice'];
    var name = parsedJson['name'];
    var shares = parsedJson['shares'];
    var ticker = parsedJson['ticker'];

    return Holding(
      averagePrice: averagePrice,
      name: name,
      shares: shares,
      ticker: ticker
    );
  }
}