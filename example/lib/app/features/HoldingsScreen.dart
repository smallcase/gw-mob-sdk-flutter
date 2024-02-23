import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:scgateway_flutter_plugin/scgateway_flutter_plugin.dart';
import 'package:scgateway_flutter_plugin_example/app/features/ConnectScreen.dart';
import 'package:scgateway_flutter_plugin_example/app/models/UserHoldingsResponse.dart';
import 'package:scgateway_flutter_plugin_example/app/global/SmartInvestingAppRepository.dart';
import 'package:scgateway_flutter_plugin_example/app/widgets/SIButton.dart';
import 'package:scgateway_flutter_plugin_example/app/widgets/SISwitch.dart';
import 'package:scgateway_flutter_plugin_example/app/widgets/SITextField.dart';

import '../widgets/SIText.dart';

class HoldingsScreen extends StatefulWidget {
  const HoldingsScreen({super.key});

  @override
  State<HoldingsScreen> createState() => HoldingsScreenState();
}

class HoldingsScreenState extends State<HoldingsScreen> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(8),
      children: [
        SIText.large(text: "STOCK HOLDINGS"),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SISwitch(
                  label: "Enable v2",
                  isEnabled: repository.isV2enabled.value,
                  onChanged: (value) {
                    setState(() {
                      repository.isV2enabled.value =
                          value; // Update repository value
                    });
                  },
                ),
              ],
            ),
            Row(
              children: [
                SISwitch(
                  label: "Enable MF",
                  isEnabled: repository.isMFTransactionEnabled.value,
                  onChanged: (value) {
                     setState(() {
                     repository.isMFTransactionEnabled.value = value;
                    });
                    
                  },
                ),
              ],
            )
          ],
        ),
        SIButton(
          label: "AUTHORIZE HOLDINGS",
          onPressed: () async {
            final reponse = await repository.triggerTransaction(
                ScgatewayIntent.AUTHORISE_HOLDINGS, null, false, context);
            repository.showAlertDialog(reponse.toString(), context);
          },
        ),
        SIButton(
          label: "IMPORT HOLDINGS",
          onPressed: () async {
            final reponse = await repository.triggerTransaction(
                ScgatewayIntent.HOLDINGS, null, false, context);
              repository.showAlertDialog(reponse.toString(), context);
          },
        ),
        SIButton(label: "SHOW HOLDINGS", onPressed: () async {
          try {
            var version = repository.isV2enabled.value ? 2 : 1;
      final response = await smartInvesting.getUserHoldings(repository.smartInvestingUserId.value ?? "", version,
          mfEnabled: repository.isMFTransactionEnabled.value);
      if (version == 2) {
        final holdingsResponse =  UserHoldingsResponse.fromJsonV2(response);
      }
      final holdingsResponse =  UserHoldingsResponse.fromJson(json.decode(response));
    } on Exception catch (e) {
      print("Gateway Exception!! getUserHoldings : $e");
      return null;
    }
        },),
        SIButton(label: "FETCH FUNDS", onPressed: () async {
            final reponse = await repository.triggerTransaction(
                ScgatewayIntent.FETCH_FUNDS, null, false, context);
              repository.showAlertDialog(reponse.toString(), context);
          }),
        SIButton(label: "RECONCILE HOLDINGS", onPressed: () async {
            final reponse = await repository.triggerTransaction(
                ScgatewayIntent.TRANSACTION, {"type": "RECONCILIATION"}, false, context);
              repository.showAlertDialog(reponse.toString(), context);
          }),
        SIText.large(text: "MF HOLDINGS"),
        SITextField(
          hint: "Enter Notes", onChanged: (value) {
            repository.notes.add(value);
          }
        ),
        SITextField(
          hint: "Enter Date", onChanged: (value) {
            repository.date.add(value);
          }
        ),
        SIButton(label: "IMPORT MF HOLDINGS", onPressed: () async {
          final assetConfig =
                        repository.date.value != null ? null : {"fromDate": repository.date.value};
            final reponse = await repository.triggerTransaction(
                ScgatewayIntent.MF_HOLDINGS_IMPORT, assetConfig, false, context, isMF: true, isPostBackStatus: true);
              repository.showAlertDialog(reponse.toString(), context); 
          }),
      ],
    );
  }
}
