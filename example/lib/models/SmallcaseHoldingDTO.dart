
class SmallcaseHoldingDTO {

  final dynamic stats;
  
  final String imageUrl;
  
  final String name;
  
  final String shortDescription;
  
  final dynamic constituents;
  
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

    var stats = parsedJson['stats'];
    var imageUrl = parsedJson['imageUrl'];
    var name = parsedJson['name'];
    var shortDescription = parsedJson['shortDescription'];
    var constituents = parsedJson['constituents'];
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