
class SmallcaseInfoDTO {
  final String? type;
  final String? name;
  final String? shortDescription;
  final String? publisherName;
  final String? blogURL;
  final String? nextUpdate;
  final String? rebalanceSchedule;
  final String? lastRebalanced;

  SmallcaseInfoDTO({
    this.type,
    this.name,
    this.shortDescription,
    this.publisherName,
    this.blogURL,
    this.nextUpdate,
    this.rebalanceSchedule,
    this.lastRebalanced,
  });

  factory SmallcaseInfoDTO.fromJson(Map<String, dynamic> parsedJson) {
    return SmallcaseInfoDTO(
      type: parsedJson['type'],
      name: parsedJson['name'],
      shortDescription: parsedJson['shortDescription'],
      publisherName: parsedJson['publisherName'],
      blogURL: parsedJson['blogURL'],
      nextUpdate: parsedJson['nextUpdate'],
      rebalanceSchedule: parsedJson['rebalanceSchedule'],
      lastRebalanced: parsedJson['lastRebalanced'],
    );
  }
}
