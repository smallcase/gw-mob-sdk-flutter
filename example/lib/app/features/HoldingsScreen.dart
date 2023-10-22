import 'package:flutter/material.dart';
import 'package:scgateway_flutter_plugin_example/app/widgets/SIButton.dart';
import 'package:scgateway_flutter_plugin_example/app/widgets/SITextField.dart';

import '../widgets/SIText.dart';

class HoldingsScreen extends StatelessWidget {
  const HoldingsScreen({super.key});

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
                SIText(text: "Enable v2"),
                Switch.adaptive(value: true, onChanged: null),
              ],
            ),
            Row(
              children: [
                SIText(text: "Enable MF"),
                Switch.adaptive(value: true, onChanged: null),
              ],
            )
          ],
        ),
        SIButton(label: "AUTHORIZE HOLDINGS"),
        SIButton(label: "IMPORT HOLDINGS"),
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
