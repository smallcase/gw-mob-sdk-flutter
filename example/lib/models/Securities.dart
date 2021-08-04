
class Securities {

  //TODO: change dynamic type
  final List<dynamic> holdings;

  Securities({
    this.holdings
});

  factory Securities.fromJson(Map<String, dynamic> parsedJson) {

    var holdings = parsedJson['holdings'];

    return Securities(
      holdings: holdings
    );

  }
}