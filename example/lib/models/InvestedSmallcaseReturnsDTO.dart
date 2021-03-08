
class InvestedSmallcaseReturnsDTO {

  final dynamic realizedInvestment;

  final dynamic realizedReturns;

  final dynamic unrealizedInvestment;

  final dynamic otherReturns;

  final dynamic accruedDivReturns;

  final dynamic networth;

  final dynamic monthly;

  final dynamic divReturns;

  final dynamic creditedDivReturns;

  final dynamic weekly;

  InvestedSmallcaseReturnsDTO({
    this.realizedInvestment,
    this.realizedReturns,
    this.unrealizedInvestment,
    this.otherReturns,
    this.accruedDivReturns,
    this.networth,
    this.monthly,
    this.divReturns,
    this.creditedDivReturns,
    this.weekly
  });

  factory InvestedSmallcaseReturnsDTO.fromJson(Map<String, dynamic> parsedJson) {

    return InvestedSmallcaseReturnsDTO(
      realizedInvestment: parsedJson['realizedInvestment'],
      realizedReturns: parsedJson['realizedReturns'],
      unrealizedInvestment: parsedJson['unrealizedInvestment'],
      otherReturns: parsedJson['otherReturns'],
      accruedDivReturns: parsedJson['accruedDivReturns'],
      networth: parsedJson['networth'],
      monthly: parsedJson['monthly'],
      divReturns: parsedJson['divReturns'],
      creditedDivReturns: parsedJson['creditedDivReturns'],
      weekly: parsedJson['weekly']
    );

  }
}