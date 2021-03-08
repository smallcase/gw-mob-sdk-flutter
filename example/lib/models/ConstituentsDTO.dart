
class ConstituentsDTO {

  final dynamic averagePrice;

  final double shares;

  final double weight;

  final dynamic returns;

  final String ticker;

  final String stockName;

  ConstituentsDTO({this.averagePrice, this.shares, this.weight, this.returns, this.ticker, this.stockName});

  factory ConstituentsDTO.fromJson(Map<String, dynamic> parsedJson) {

    return ConstituentsDTO(
      averagePrice: parsedJson['averagePrice'],
      shares: parsedJson['shares'],
      weight: parsedJson['weight'],
      returns: parsedJson['returns'],
      ticker: parsedJson['ticker'],
      stockName: parsedJson['stockName']
    );

  }
}