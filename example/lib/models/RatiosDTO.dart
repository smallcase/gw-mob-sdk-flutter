
class RatiosDTO {

  final dynamic jsonMember52wHigh;

  final dynamic jsonMember52wLow;

  final dynamic divYield;

  final dynamic divYieldDifferential;

  final dynamic largeCapPercentage;

  final dynamic marketCapCategory;

  final dynamic midCapPercentage;

  final dynamic pb;

  final dynamic pbDiscount;

  final dynamic pe;

  final dynamic peDiscount;

  final dynamic smallCapPercentage;

  final dynamic cagr;

  final dynamic momentumRank;

  final dynamic risk;

  final dynamic sharpe;

  final dynamic ema;

  final dynamic momentum;

  final dynamic lastCloseEma;

  final dynamic sharpeRatio;

  RatiosDTO({
    this.jsonMember52wHigh,
    this.jsonMember52wLow,
    this.divYield,
    this.divYieldDifferential,
    this.largeCapPercentage,
    this.marketCapCategory,
    this.midCapPercentage,
    this.pb,
    this.pbDiscount,
    this.pe,
    this.peDiscount,
    this.smallCapPercentage,
    this.cagr,
    this.momentumRank,
    this.risk,
    this.sharpe,
    this.ema,
    this.momentum,
    this.lastCloseEma,
    this.sharpeRatio
});

  factory RatiosDTO.fromJson(Map<String, dynamic> parsedJson) {

    return RatiosDTO(
      jsonMember52wHigh: parsedJson['jsonMember52wHigh'],
      jsonMember52wLow: parsedJson['jsonMember52wLow'],
      divYield: parsedJson['divYield'],
      divYieldDifferential: parsedJson['divYieldDifferential'],
      largeCapPercentage: parsedJson['largeCapPercentage'],
      marketCapCategory: parsedJson['marketCapCategory'],
      midCapPercentage: parsedJson['midCapPercentage'],
      pb: parsedJson['pb'],
      pbDiscount: parsedJson['pbDiscount'],
      pe: parsedJson['pe'],
      peDiscount: parsedJson['peDiscount'],
      smallCapPercentage: parsedJson['smallCapPercentage'],
      cagr: parsedJson['cagr'],
      momentumRank: parsedJson['momentumRank'],
      risk: parsedJson['risk'],
      sharpe: parsedJson['sharpe'],
      ema: parsedJson['ema'],
      momentum: parsedJson['momentum'],
      lastCloseEma: parsedJson['lastCloseEma'],
      sharpeRatio: parsedJson['sharpeRatio']
    );

  }
}