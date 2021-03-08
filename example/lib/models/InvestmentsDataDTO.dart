
import 'package:scgateway_flutter_plugin_example/models/ActionsDTO.dart';

import 'InvestmentItemDTO.dart';

class InvestmentsDataDTO {

  final InvestmentItemDTO investmentItem;

  final ActionsDTO actions;

  InvestmentsDataDTO({this.investmentItem, this.actions});

  factory InvestmentsDataDTO.fromJson(Map<String, dynamic> parsedJson) {

    return InvestmentsDataDTO(
      investmentItem: InvestmentItemDTO.fromJson(parsedJson['investment']),
      actions: ActionsDTO.fromJson(parsedJson['actions'])
    );

  }

}