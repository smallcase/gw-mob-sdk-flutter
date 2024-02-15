
import 'SmallcaseInfoDTO.dart';
import 'SmallcaseStatsDTO.dart';

class SmallcasesDTO {

  final SmallcaseInfoDTO? info;

  final SmallcaseStatsDTO? stats;

  final String? id;

  final String? scid;

  final String? newsTag;

  final dynamic initialIndex;

  final int? keywordsMatchCount;

  SmallcasesDTO({ this.info, this.stats, this.id, this.scid, this.newsTag, this.initialIndex, this.keywordsMatchCount });

  factory SmallcasesDTO.fromJson(Map<String, dynamic> parsedJson) {

    return SmallcasesDTO(
      info: SmallcaseInfoDTO.fromJson(parsedJson['info']),
      stats: SmallcaseStatsDTO.fromJson(parsedJson['stats']),
      id: parsedJson['id'],
      scid: parsedJson['scid'],
      newsTag: parsedJson['newsTag'],
      initialIndex: parsedJson['initialIndex'],
      keywordsMatchCount: parsedJson['keywordsMatchCount']
    );

  }
}