import 'package:flutter/material.dart';
import 'package:scgateway_flutter_plugin/scgateway_flutter_plugin.dart';
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
          },
        ),
        SIButton(label: "SHOW HOLDINGS"),
        SIButton(label: "FETCH FUNDS"),
        SIButton(label: "RECONCILE HOLDINGS"),
        SIText.large(text: "MF HOLDINGS"),
        SITextField(
          hint: "Enter Notes",
        ),
        SITextField(
          hint: "Enter Date",
        ),
        SIButton(label: "IMPORT MF HOLDINGS"),
      ],
    );
  }
}
