
class InvestedSmallcaseReturnsDTO {

  final double realizedInvestment;

  final double realizedReturns;

  final double unrealizedInvestment;

  final double otherReturns;

  final double accruedDivReturns;

  final double networth;

  final double monthly;

  final double divReturns;

  final double creditedDivReturns;

  final double weekly;

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