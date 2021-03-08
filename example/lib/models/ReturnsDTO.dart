
class ReturnsDTO {

  final dynamic realizedInvestment;

  final dynamic realizedReturns;

  final dynamic otherReturns;

  final dynamic divReturns;

  final dynamic accruedDivReturns;

  final dynamic creditedDivReturns;

  ReturnsDTO({this.realizedInvestment, this.realizedReturns, this.otherReturns, this.divReturns, this.accruedDivReturns, this.creditedDivReturns});

  factory ReturnsDTO.fromJson(Map<String, dynamic> parsedJson) {

    return ReturnsDTO(
      realizedInvestment: parsedJson['realizedInvestment'],
      realizedReturns: parsedJson['realizedReturns'],
      otherReturns: parsedJson['otherReturns'],
      divReturns: parsedJson['divReturns'],
      accruedDivReturns: parsedJson['accruedDivReturns'],
      creditedDivReturns: parsedJson['creditedDivReturns']
    );

  }

}