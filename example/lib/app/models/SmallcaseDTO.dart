
import 'SmallcaseInfoDTO.dart';
import 'SmallcaseStatsDTO.dart';

class SmallcasesDTO {
  final SmallcaseInfoDTO? info;
  final SmallcaseStatsDTO? stats;
  final String id;
  final String scid;
  final String newsTag;
  final dynamic initialIndex;
  final int keywordsMatchCount;

  SmallcasesDTO({
    required this.id,
    required this.scid,
    required this.newsTag,
    required this.initialIndex,
    required this.keywordsMatchCount,
    this.info, // Make info nullable
    this.stats,
  });

  factory SmallcasesDTO.fromJson(Map<String, dynamic> parsedJson) {
  return SmallcasesDTO(
    id: parsedJson['id'] ?? '', // Provide a default value if 'id' is null
    scid: parsedJson['scid'] ?? '', // Provide a default value if 'scid' is null
    newsTag: parsedJson['newsTag'] ?? '', // Provide a default value if 'newsTag' is null
    initialIndex: parsedJson['initialIndex'], // 'initialIndex' can be null if it's dynamic
    keywordsMatchCount: parsedJson['keywordsMatchCount'] ?? 0, // Provide a default value if 'keywordsMatchCount' is null
    info: parsedJson['info'] != null ? SmallcaseInfoDTO.fromJson(parsedJson['info']) : null,
    stats: parsedJson['stats'] != null ? SmallcaseStatsDTO.fromJson(parsedJson['stats']) : null,
  );
}
}
