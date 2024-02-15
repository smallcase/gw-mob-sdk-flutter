
import 'package:scgateway_flutter_plugin_example/app/features/SmallcaseDTO.dart';
import 'package:scgateway_flutter_plugin_example/app/features/StocksDTO.dart';

import 'FlagsDTO.dart';
import 'PublisherDTO.dart';


class NewsDataDTO {

  final String? id;

  final PublisherDTO? publisher;

  final FlagsDTO? flags;

  final List<String>? tags;

  final List<String>? sidKeywords;

  final List<String>? smallcaseKeywords;

  final String? source;

  final String? link;

  final String? date;

  final String? headline;

  final String? summary;

  final String? imageUrl;

  final String? status;

  final List<SmallcasesDTO>? smallcases;

  final List<StocksDTO>? stocks;

  final int? V;

  NewsDataDTO({this.id,
    this.publisher,
    this.flags,
    this.tags,
    this.sidKeywords,
    this.smallcaseKeywords,
    this.source,
    this.link,
    this.date,
    this.headline,
    this.summary,
    this.imageUrl,
    this.status,
    this.smallcases,
    this.stocks,
    this.V
  });

  factory NewsDataDTO.fromJson(Map<String, dynamic> parsedJson) {

    // var tagsFromJson  = parsedJson['tags'];
    // List<String> tagsList = tagsFromJson.cast<String>();

    // var sidKeywordsFromJson = parsedJson['sidKeywords'];
    // List<String> sidKeywordsList = sidKeywordsFromJson.cast<String>();

    // var smallcasesListFromJson = parsedJson['smallcases'] as List;
    // List<SmallcasesDTO> smallcasesList = smallcasesListFromJson.map((i) => SmallcasesDTO.fromJson(i)).toList();

    // var stocksFromJson = parsedJson['stocks'] as List;
    // List<StocksDTO> stocksList = stocksFromJson.map((i) => StocksDTO.fromJson(i)).toList();

    return NewsDataDTO(
      id: parsedJson['id'],
      publisher: PublisherDTO.fromJson(parsedJson['publisher']),
      flags: FlagsDTO.fromJson(parsedJson['flags']),
      tags: null,
      sidKeywords: null,
      source: parsedJson['source'],
      link: parsedJson['link'],
      date: parsedJson['date'],
      headline: parsedJson['headline'],
      summary: parsedJson['summary'],
      imageUrl: parsedJson['imageUrl'],
      status: parsedJson['status'],
      smallcases: null,
      stocks: null,
      V: parsedJson['__v']
    );

  }

}