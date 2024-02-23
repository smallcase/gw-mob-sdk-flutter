import 'package:scgateway_flutter_plugin_example/app/models/SmallcaseHoldingDTO.dart';
import 'package:scgateway_flutter_plugin_example/app/models/Stats.dart';

class Private {
  final String? scid;

  final String? name;

  final String? investmentDetailsUrl;

  final String? shortDescription;

  final String? imageUrl;

  final Stats? stats;

  Private(
      {this.scid,
      this.name,
      this.investmentDetailsUrl,
      this.shortDescription,
      this.imageUrl,
      this.stats});

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
        shortDescription: shortDes,
        imageUrl: imageUrl,
        stats: stats);
  }
}

class PrivateV2 {
  List<SmallcaseHoldingDTO>? investments;
  PrivateV2({
    this.investments,
  });

  factory PrivateV2.fromMap(Map<String, dynamic> map) => PrivateV2(
      investments: (map['investments'] as List)
          ?.map((e) => SmallcaseHoldingDTO.fromJson(e))
          ?.toList());

  @override
  String toString() => 'PrivateV2(investments: $investments)';
}
