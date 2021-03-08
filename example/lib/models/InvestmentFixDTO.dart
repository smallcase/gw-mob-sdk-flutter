
class InvestmentFixDTO {

  final bool hidden;

  final String iscid;

  final String date;

  final String name ;

  final String batchId;

  final String scid;

  final String source;

  final dynamic filled;

  final dynamic quantity;

  final String originalLabel;

  InvestmentFixDTO({
    this.hidden,
    this.iscid,
    this.date,
    this.name,
    this.batchId,
    this.scid,
    this.source,
    this.filled,
    this.quantity,
    this.originalLabel
});

  factory InvestmentFixDTO.fromJson(Map<String, dynamic> parsedJson) {

    return InvestmentFixDTO(
      hidden: parsedJson['hidden'],
      iscid: parsedJson['iscid'],
      date: parsedJson['date'],
      name: parsedJson['name'],
      batchId: parsedJson['batchId'],
      scid: parsedJson['scid'],
      source: parsedJson['source'],
      filled: parsedJson['filled'],
      quantity: parsedJson['quantity'],
      originalLabel: parsedJson['originalLabel']
    );

  }

}