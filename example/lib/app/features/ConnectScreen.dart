import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:scgateway_flutter_plugin/scgateway_flutter_plugin.dart';

import 'package:scgateway_flutter_plugin_example/app/global/SIConfigs.dart';
import 'package:scgateway_flutter_plugin_example/app/global/SmartInvestingAppRepository.dart';
import 'package:scgateway_flutter_plugin_example/app/widgets/SIButton.dart';
import 'package:scgateway_flutter_plugin_example/app/widgets/SIEnvironmentController.dart';
import 'package:scgateway_flutter_plugin_example/app/widgets/SISwitch.dart';
import 'package:scgateway_flutter_plugin_example/app/widgets/SIText.dart';
import 'package:scgateway_flutter_plugin_example/app/widgets/SITextField.dart';
import 'package:scgateway_flutter_plugin_example/smartinvesting.dart';

import '../../main.dart';

final gatewayEnvironments = [
  ScGatewayConfig.prod(),
  ScGatewayConfig.dev(),
  ScGatewayConfig.stag()
];

//  SmartInvesting get smartInvesting {
//   return SmartInvesting.fromEnvironment(repository.scGatewayConfig.value);
// }

SmartInvesting smartInvesting = SmartInvestingAppRepository.smartInvesting;
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
        SIEnvironmentController(repository: SmartInvestingAppRepository.singleton()),
        StreamBuilder(
          stream: SmartInvestingAppRepository.singleton().scGatewayConfig,
          builder: (context, snapshot) {
            final data = snapshot.data;
            if (data == null)
              return Text("scGatewayConfig is not set in ${SmartInvestingAppRepository.singleton()}");
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SITextField(hint: "Enter gateway name", text: data.gatewayName),
                SISwitch(
                  label: "Leprechaun Mode:",
                  isEnabled: data.isLeprechaunEnabled,
                  onChanged: (value) {
                    SmartInvestingAppRepository.singleton().scGatewayConfig.value =
                        data.copyWith(isLeprechaunEnabled: value);
                  },
                ),
                SISwitch(
                  label: "Amo Mode:",
                  isEnabled: data.isAmoEnabled,
                  onChanged: (value) {
                    SmartInvestingAppRepository.singleton().scGatewayConfig.value =
                        data.copyWith(isAmoEnabled: value);
                  },
                ),
                SITextField(
                  hint: "Smart Investing User Id",
                  onChanged: (value) {
                    SmartInvestingAppRepository.singleton().smartInvestingUserId.add(value);
                },
                ),
                SIButton(label: "Fetch AuthToken From SmartInvesting", onPressed: () async {
                  final loginResponse = await smartInvesting
                  .userLogin(userID: SmartInvestingAppRepository.singleton().smartInvestingUserId.value);
                  SmartInvestingAppRepository.singleton().scGatewayConfig.value = data.copyWith(customAuthToken: loginResponse["smallcaseAuthToken"]);
                  SmartInvestingAppRepository.singleton().showAlertDialog(loginResponse.toString(),context);
                },
                ),
                SITextField(
                  hint: "Custom Auth Token (JwT)",
                  text: data.customAuthToken,
                  onChanged: (value) {
                    SmartInvestingAppRepository.singleton().scGatewayConfig.value =
                        data.copyWith(customAuthToken: value);
                  }
                ),
                Wrap(
                  children: [
                    SIButton(label: "SETUP", onPressed: () async {
                    final environmentResponse = await  ScgatewayFlutterPlugin.setConfigEnvironment(
                        SmartInvestingAppRepository.singleton().scGatewayConfig.value.environment,
                        SmartInvestingAppRepository.singleton().scGatewayConfig.value.gatewayName,
                        SmartInvestingAppRepository.singleton().scGatewayConfig.value.isLeprechaunEnabled,
                        [],
                        isAmoenabled: SmartInvestingAppRepository.singleton().scGatewayConfig.value.isAmoEnabled);
                        final initResponse = await ScgatewayFlutterPlugin.initGateway(SmartInvestingAppRepository.singleton().scGatewayConfig.value.customAuthToken ?? "");
                        SmartInvestingAppRepository.singleton().showAlertDialog(initResponse.toString(), context);
                    },
                    ),
                    SIButton(label: "CONNECT", onPressed: () async {
                    SmartInvestingAppRepository.singleton().triggerTransaction(ScgatewayIntent.CONNECT, null, false, context);
                    },
                    ),
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
                      checkmarkColor: Colors.white,
                      onSelected: (value) {
                        setState(() {
                          SmartInvestingAppRepository.singleton().isMFTransactionEnabled.add(value); 
                      });
                      },
                      label: Text("MF"),
                      selected: SmartInvestingAppRepository.singleton().isMFTransactionEnabled.value ?? false,
                      elevation: 0,
                      selectedColor: Colors.green,
                      
                    ),
                  ],
                ),
                SITextField(
                  hint: "Enter Transaction Id",
                  onChanged: (value) {
                    SmartInvestingAppRepository.singleton().transactionID.add(value);
                }
                ),
                Wrap(
                  children: [
                    SIButton(label: "Copy", onPressed: () {
                      FlutterClipboard.copy(SmartInvestingAppRepository.singleton().transactionID.value);
                    },),
                    SIButton(label: "Trigger", onPressed: () {
                    SmartInvestingAppRepository.singleton().triggerTransaction(null, null, true, context, isMF: SmartInvestingAppRepository.singleton().isMFTransactionEnabled.value);
          },),
                    SIButton(label: "Search Postback", onPressed: () {

                      //call the postback function here
                    },),
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
