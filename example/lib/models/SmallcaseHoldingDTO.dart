
import 'package:scgateway_flutter_plugin_example/models/ConstituentsItem.dart';
import 'package:scgateway_flutter_plugin_example/models/Stats.dart';

class SmallcaseHoldingDTO {

  final Stats stats;
  
  final String imageUrl;
  
  final String name;
  
  final String shortDescription;
  
  final List<ConstituentsItem> constituents;
  
  final String scid;

  SmallcaseHoldingDTO({
    this.stats,
    this.imageUrl,
    this.name,
    this.shortDescription,
    this.constituents,
    this.scid
});

  factory SmallcaseHoldingDTO.fromJson(Map<String, dynamic> parsedJson) {

    var stats = Stats.fromJson(parsedJson['stats']);
    var imageUrl = parsedJson['imageUrl'];
    var name = parsedJson['name'];
    var shortDescription = parsedJson['shortDescription'];
    var constituentsJson = parsedJson['constituents'] as List;
    List<ConstituentsItem> constituents = constituentsJson.map((i) => ConstituentsItem.fromJson(i)).toList();

    var scid = parsedJson['scid'];

    return SmallcaseHoldingDTO(
      stats: stats,
      imageUrl: imageUrl,
      name: name,
      shortDescription: shortDescription,
      constituents: constituents,
      scid: scid
    );

  }

}