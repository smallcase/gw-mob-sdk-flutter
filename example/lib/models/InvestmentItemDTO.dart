
import 'CurrentConfigDTO.dart';
import 'InvestedSmallcaseReturnsDTO.dart';
import 'StatsDTO.dart';

class InvestmentItemDTO {

  final String date;

  final String recommendedAction;

  final StatsDTO stats;

  final String name;

  final String iscid;

  final InvestedSmallcaseReturnsDTO returns;

  final CurrentConfigDTO currentConfig;

  final String shortDescription;

  final dynamic version;

  final String scid;

  final String status;

  InvestmentItemDTO({this.date, this.recommendedAction, this.stats, this.name, this.iscid, this.returns, this.currentConfig, this.shortDescription, this.version, this.scid, this.status});

  factory InvestmentItemDTO.fromJson(Map<String, dynamic> parsedJson) {

    return InvestmentItemDTO(
      date: parsedJson['date'],
      recommendedAction: parsedJson['recommendedAction'],
      stats: StatsDTO.fromJson(parsedJson['stats']),
      name: parsedJson['name'],
      iscid: parsedJson['iscid'],
      returns: InvestedSmallcaseReturnsDTO.fromJson(parsedJson['returns']),
      currentConfig: CurrentConfigDTO.fromJson(parsedJson['currentConfig']),
      shortDescription: parsedJson['shortDescription'],
      version: parsedJson['version'],
      scid: parsedJson['scid'],
      status: parsedJson['status']
    );

  }
}