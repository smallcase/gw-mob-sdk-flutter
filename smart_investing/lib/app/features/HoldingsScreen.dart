import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:scgateway_flutter_plugin/scgateway_flutter_plugin.dart';

import '../../smartinvesting.dart';
import '../global/SmartInvestingAppRepository.dart';
import '../widgets/SIButton.dart';
import '../widgets/SISwitch.dart';
import '../widgets/SIText.dart';
import '../widgets/SITextField.dart';

class HoldingsScreen extends StatefulWidget {
  const HoldingsScreen({super.key});

  @override
  State<HoldingsScreen> createState() => HoldingsScreenState();
}

class HoldingsScreenState extends State<HoldingsScreen> {
  @override
  Widget build(BuildContext context) {
        return StreamBuilder(
      stream: repository.scGatewayConfig, // Assuming this is the relevant stream
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data == null) {
          // Handle the case where data is not available
          return CircularProgressIndicator(); // or any other placeholder widget
        } else {
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
                  isEnabled: data.isV2enabled,
                  onChanged: (value) {
                     repository.scGatewayConfig.value =
                        data.copyWith(isV2enabled: value);
                  },
                ),
              ],
            ),
            Row(
              children: [
                SISwitch(
                  label: "Enable MF",
                  isEnabled: data.isMFTransactionEnabled,
                  onChanged: (value) {
                    repository.scGatewayConfig.value =
                        data.copyWith(isMFTransactionEnabled: value);
                  },
                ),
              ],
            )
          ],
        ),
         SITextField(
                  hint: "Smart Investing User Id",
                  onChanged: (value) {
                    repository.smartInvestingUserId.add(value);
                  },
                ),
        SIButton(
          label: "AUTHORIZE HOLDINGS",
          onPressed: () async {
            final reponse = await repository.triggerTransaction(
                ScgatewayIntent.AUTHORISE_HOLDINGS, null, false, context);
          },
        ),
        SIButton(
          label: "IMPORT HOLDINGS",
          onPressed: () async {
            final reponse = await repository.triggerTransaction(
                ScgatewayIntent.HOLDINGS, null, false, context);
              
          },
        ),
 SIButton(
  label: "SHOW HOLDINGS",
  onPressed: () async {
    try {
      var version = data.isV2enabled ? 2 : 1;
      print("HEY LOL HERE IS YOUR SMARTINVESTING USER ID: ${repository.smartInvestingUserId.value}");
      final response = await smartInvesting.getUserHoldings(repository.smartInvestingUserId.value ?? "", version, mfEnabled: data.isMFTransactionEnabled);
      repository.showAlertDialog(response, context);
    } catch (e) {
      repository.showAlertDialog("Error: ${e.toString()}", context);
      print("Exception!! getUserHoldings : $e");
    }
  },
),
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
        );
}
}
