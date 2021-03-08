
import 'InvestmentFixDTO.dart';

class ActionsDTO {

  final List<dynamic> rebalance;

  final List<InvestmentFixDTO> fix;

  final List<dynamic> sip;

  ActionsDTO({this.rebalance, this.fix, this.sip});

  factory ActionsDTO.fromJson(Map<String, dynamic> parsedJson) {

    var rebalanceJson = parsedJson['rebalance'];
    List<dynamic> rebalanceList = rebalanceJson.cast<dynamic>();

    var fixJson = parsedJson['fix'] as List;
    List<InvestmentFixDTO> fixList = fixJson.map((i) => InvestmentFixDTO.fromJson(i)).toList();

    var sipJson = parsedJson['sip'];
    List<dynamic> sipList = sipJson.cast<dynamic>();

    return ActionsDTO(
      rebalance: rebalanceList,
      fix: fixList,
      sip: sipList
    );

  }

}