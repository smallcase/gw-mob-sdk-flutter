
class ConstituentsItem {

  final int shares;

  final String ticker;

  ConstituentsItem({
    this.shares,
    this.ticker
});

  factory ConstituentsItem.fromJson(Map<String, dynamic> parsedJson) {

    var shares = parsedJson['shares'];
    var ticker = parsedJson['ticker'];

    return ConstituentsItem(
      shares: shares,
      ticker: ticker
    );

  }

}