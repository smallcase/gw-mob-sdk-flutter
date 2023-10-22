import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:scgateway_flutter_plugin_example/app/global/SIConfigs.dart';
import 'package:scgateway_flutter_plugin_example/app/widgets/SIButton.dart';
import 'package:scgateway_flutter_plugin_example/app/widgets/SIEnvironmentController.dart';
import 'package:scgateway_flutter_plugin_example/app/widgets/SISwitch.dart';
import 'package:scgateway_flutter_plugin_example/app/widgets/SIText.dart';
import 'package:scgateway_flutter_plugin_example/app/widgets/SITextField.dart';

import '../../main.dart';

final gatewayEnvironments = [
  ScGatewayConfig.prod(),
  ScGatewayConfig.dev(),
  ScGatewayConfig.stag()
];

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 8),
      children: [
        SIEnvironmentController(repository: repository),
        StreamBuilder(
          stream: repository.scGatewayConfig,
          builder: (context, snapshot) {
            final data = snapshot.data;
            if (data == null)
              return Text("scGatewayConfig is not set in $repository");
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SITextField(hint: "Enter gateway name", text: data.gatewayName),
                SISwitch(
                  label: "Leprechaun Mode:",
                  isEnabled: data.isLeprechaunEnabled,
                  onChanged: (value) {
                    repository.scGatewayConfig.value =
                        data.copyWith(isLeprechaunEnabled: value);
                  },
                ),
                SISwitch(
                  label: "Amo Mode:",
                  isEnabled: data.isAmoEnabled,
                  onChanged: (value) {
                    repository.scGatewayConfig.value =
                        data.copyWith(isAmoEnabled: value);
                  },
                ),
                SITextField(
                  hint: "Smart Investing User Id",
                ),
                SITextField(
                  hint: "Custom Auth Token (JwT)",
                ),
                Wrap(
                  children: [
                    SIButton(label: "SETUP"),
                    SIButton(label: "CONNECT"),
                  ],
                ),
                SizedBox.square(dimension: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SIText.large(
                      text: "Trigger Txn with Id",
                    ),
                    InputChip(
                      // checkmarkColor: Colors.white,
                      onSelected: (value) {},
                      label: Text("MF"),
                      selected: false,
                      elevation: 0,
                      // selectedColor: Colors.green,
                    ),
                  ],
                ),
                SITextField(
                  hint: "Enter Transaction Id",
                ),
                Wrap(
                  children: [
                    SIButton(label: "Copy"),
                    SIButton(label: "Trigger"),
                    SIButton(label: "Search Postback"),
                  ],
                )
              ],
            );
          },
        ),
      ],
    );
  }
}
