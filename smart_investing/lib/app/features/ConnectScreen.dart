import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:scgateway_flutter_plugin/scgateway_flutter_plugin.dart';

import '../../smartinvesting.dart';
import '../global/SIConfigs.dart';
import '../global/SmartInvestingAppRepository.dart';
import '../widgets/SIButton.dart';
import '../widgets/SIEnvironmentController.dart';
import '../widgets/SISwitch.dart';
import '../widgets/SIText.dart';
import '../widgets/SITextField.dart';

final gatewayEnvironments = [
  ScGatewayConfig.prod(),
  ScGatewayConfig.dev(),
  ScGatewayConfig.stag()
];

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
        SIEnvironmentController(repository: repository),
        StreamBuilder(
          stream: repository.scGatewayConfig,
          builder: (context, snapshot) {
            final data = snapshot.data;
            if (data == null)
              return Text("scGatewayConfig is not set in ${repository}");
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
                  onChanged: (value) {
                    repository.smartInvestingUserId.add(value);
                  },
                ),
                SIButton(
                  label: "Fetch AuthToken From SmartInvesting",
                  onPressed: () async {
                    print(
                        "THE SMARTINVESTING USER ID INSIDE FETCH AUTH TOKEN IS ${repository.smartInvestingUserId.value}");
                    final loginResponse = await smartInvesting.userLogin(
                        userID: repository.smartInvestingUserId.value);
                    repository.scGatewayConfig.value = data.copyWith(
                        customAuthToken: loginResponse["smallcaseAuthToken"]);
                    repository.showAlertDialog(
                        loginResponse.toString(), context);
                  },
                ),
                SITextField(
                    hint: "Custom Auth Token (JwT)",
                    text: data.customAuthToken,
                    onChanged: (value) {
                      repository.scGatewayConfig.value =
                          data.copyWith(customAuthToken: value);
                    }),
                Wrap(
                  children: [
                    SIButton(
                      label: "SETUP",
                      onPressed: () async {
                        final environmentResponse =
                            await ScgatewayFlutterPlugin.setConfigEnvironment(
                                repository.scGatewayConfig.value.environment,
                                repository.scGatewayConfig.value.gatewayName,
                                repository
                                    .scGatewayConfig.value.isLeprechaunEnabled,
                                [],
                                isAmoenabled: repository
                                    .scGatewayConfig.value.isAmoEnabled);
                        if (repository.scGatewayConfig.value.customAuthToken ==
                            null) {
                          final loginResponse = await smartInvesting.userLogin(
                              userID: repository.smartInvestingUserId.value);
                          repository.scGatewayConfig.value = data.copyWith(
                              customAuthToken:
                                  loginResponse["smallcaseAuthToken"]);
                        }
                        final initResponse =
                            await ScgatewayFlutterPlugin.initGateway(repository
                                    .scGatewayConfig.value.customAuthToken ??
                                "");
                        repository.showAlertDialog(
                            initResponse.toString(), context);
                      },
                    ),
                    SIButton(
                      label: "CONNECT",
                      onPressed: () async {
                        // final transactionId =
                        //     await SmartInvesting.fromEnvironment(
                        //             repository.scGatewayConfig.value)
                        //         .getTransactionId(
                        //             repository.smartInvestingUserId.value ?? "",
                        //             ScgatewayIntent.CONNECT,
                        //             null);
                        // final response = await ScgatewayFlutterPlugin
                        //         .triggerGatewayTransaction(transactionId) ??
                        //     "";
                        // repository.showAlertDialog(
                        //     response.toString(), context);
                        repository.triggerTransaction(
                            ScgatewayIntent.CONNECT, null, false, context);
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
                        repository.scGatewayConfig.value =
                            data.copyWith(isMFTransactionEnabled: value);
                      },
                      label: Text("MF"),
                      selected: data.isMFTransactionEnabled,
                      elevation: 0,
                      selectedColor: Colors.green,
                    ),
                  ],
                ),
                SITextField(
                    hint: "Enter Transaction Id",
                    onChanged: (value) {
                      repository.transactionID.add(value);
                    }),
                Wrap(
                  children: [
                    SIButton(
                      label: "Copy",
                      onPressed: () {
                        FlutterClipboard.copy(repository.transactionID.value);
                      },
                    ),
                    SIButton(
                      label: "Trigger",
                      onPressed: () {
                        repository.triggerTransaction(null, null, true, context,
                            isMF: data.isMFTransactionEnabled);
                      },
                    ),
                    SIButton(
                      label: "Search Postback",
                      onPressed: () {
                        //call the postback function here
                      },
                    ),
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
