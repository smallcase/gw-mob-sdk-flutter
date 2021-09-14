
import 'package:scgateway_flutter_plugin_example/models/Stats.dart';

class Private {

  final String scid;
  
  final String name;
  
  final String investmentDetailsUrl;
  
  final String shortDes;
  
  final String imageUrl;

  final Stats stats;

  Private({
    this.scid,
    this.name,
    this.investmentDetailsUrl,
    this.shortDes,
    this.imageUrl,
    this.stats
});

  factory Private.fromJson(Map<String, dynamic> parsedJson) {

    var scid = parsedJson['scid'];
    var name = parsedJson['name'];
    var investmentDetailsUrl = parsedJson['investmentDetailsURL'];
    var shortDes = parsedJson['shortDescription'];
    var imageUrl = parsedJson['imageUrl'];
    var stats = Stats.fromJson(parsedJson['stats']);

    return Private(
      scid: scid,
      name: name,
      investmentDetailsUrl: investmentDetailsUrl,
      shortDes: shortDes,
      imageUrl: imageUrl,
      stats: stats
    );

  }
}