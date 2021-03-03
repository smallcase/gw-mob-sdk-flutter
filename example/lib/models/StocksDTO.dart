
class StocksDTO {

  final String sid;

  final dynamic initialPrice;

  StocksDTO({this.sid, this.initialPrice});

  factory StocksDTO.fromJson(Map<String, dynamic> parsedJson) {

    return StocksDTO(
      sid: parsedJson['sid'],
      initialPrice: ['initialPrice']
    );
  }

}