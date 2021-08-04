
import 'package:scgateway_flutter_plugin_example/models/Holding.dart';

class Securities {

  final List<Holding> holdings;

  Securities({
    this.holdings
});

  factory Securities.fromJson(Map<String, dynamic> parsedJson) {

    var holdingsJson = parsedJson['holdings'] as List;
    List<Holding> holdings = holdingsJson.map((e) => Holding.fromJson(e)).toList();

    return Securities(
      holdings: holdings
    );

  }
}