
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

  factory Private.fromJson(Map<dynamic, dynamic> parsedJson) {

    var scid = parsedJson['scid'];
    var name = parsedJson['name'];
    var investmentDetailsUrl = parsedJson['investmentDetailsUrl'];
    var shortDes = parsedJson['shortDes'];
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