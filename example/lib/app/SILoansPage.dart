import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:scgateway_flutter_plugin_example/app/global/SmartInvestingAppRepository.dart';
import 'package:scgateway_flutter_plugin_example/app/widgets/SIButton.dart';
import 'package:scgateway_flutter_plugin_example/app/widgets/SISwitch.dart';
import 'package:scgateway_flutter_plugin_example/app/widgets/SIText.dart';
import 'package:scgateway_flutter_plugin_example/app/widgets/SITextField.dart';
import 'package:scloans/ScLoan.dart';

import '../main.dart';
import 'widgets/SIEnvironmentController.dart';

class SILoansPage extends StatelessWidget {
  const SILoansPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SIText.xlarge(text: "LOANS"),
        actions: [
          SIButton(
            label: "Gateway",
            onPressed: () => {
              repository.appState.add("/"),
              context.go(repository.appState.value)
            },
          )
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 8),
          children: [
            SIEnvironmentController(repository: repository),
            StreamBuilder(
              stream: repository.scLoanConfig,
              builder: (context, snapshot) {
                final data = snapshot.data;
                if (data == null) {
                  return const SizedBox();
                }
                return Column(
                  children: [
                    SITextField(
                        hint: "Enter Gateway Name",
                        onChanged: (value) {
                          repository.scLoanConfig.value =
                              data.copyWith(gatewayName: value);
                        }),
                    SITextField(
                        hint: "Enter Custom Interaction Token",
                        onChanged: (value) {
                          repository.scLoanConfig.value =
                              data.copyWith(customInteractionToken: value);
                        }),
                  ],
                );
              },
            ),
            Wrap(
              spacing: 12,
              children: [
                SIButton(
                  label: "Setup",
                  onPressed: () async {
                    try {
                      final response = await ScLoan.setup(ScLoanConfig(
                          repository.scLoanConfig.value.environment,
                          repository.scLoanConfig.value.gatewayName));
                      repository.showAlertDialog(response.toString(), context);
                    } on ScLoanError catch (e) {
                      repository.showAlertDialog(e.toString(), context);
                    }
                  },
                ),
                SIButton(
                  label: "Apply",
                  onPressed: () async {
                    try {
                      final response = await ScLoan.apply(ScLoanInfo(repository
                              .scLoanConfig.value.customInteractionToken ??
                          ""));
                      repository.showAlertDialog(response.toString(), context);
                    } on ScLoanError catch (e) {
                      repository.showAlertDialog(e.toString(), context);
                    }
                  },
                ),
                SIButton(
                    label: "Pay",
                    onPressed: () async {
                      try {
                        final response = await ScLoan.pay(ScLoanInfo(repository
                                .scLoanConfig.value.customInteractionToken ??
                            ""));
                        repository.showAlertDialog(
                            response.toString(), context);
                      } on ScLoanError catch (e) {
                        repository.showAlertDialog(e.toString(), context);
                      }
                    }),
                SIButton(
                    label: "Withdraw",
                    onPressed: () async {
                      try {
                        final response = await ScLoan.withdraw(ScLoanInfo(
                            repository.scLoanConfig.value
                                    .customInteractionToken ??
                                ""));
                        repository.showAlertDialog(
                            response.toString(), context);
                      } on ScLoanError catch (e) {
                        repository.showAlertDialog(e.toString(), context);
                      }
                    }),
                SIButton(
                    label: "Service",
                    onPressed: () async {
                      try {
                        final response = await ScLoan.service(ScLoanInfo(
                            repository.scLoanConfig.value
                                    .customInteractionToken ??
                                ""));
                        repository.showAlertDialog(
                            response.toString(), context);
                      } on ScLoanError catch (e) {
                        repository.showAlertDialog(e.toString(), context);
                      }
                    }),
              ],
            ),
            StreamBuilder(
              stream: repository.siConfig,
              builder: (context, snapshot) {
                final data = snapshot.data;
                return Wrap(
                  children: [
                    SITextField(
                      text: data?.loansUserId,
                      hint: "Enter SI user Id",
                    ),
                    SIButton(label: "Get User")
                  ],
                );
              },
            ),
            SIText.large(text: "Create a New User"),
            Wrap(
              children: [
                SITextField(hint: "Enter new user Id"),
                SITextField(hint: "Enter PAN"),
                SITextField(hint: "Enter DOB"),
                SITextField(hint: "Enter Email"),
                SITextField(hint: "Enter Phone"),
                SITextField(hint: "Enter Bank Acc. no."),
                SITextField(hint: "Enter IFSC code"),
                SITextField(hint: "Enter Account Type"),
                SITextField(hint: "Enter MF Holdings Json"),
                SISwitch(
                  label: "Enable Lien Marking",
                  isEnabled: false,
                  onChanged: (value) {},
                ),
              ],
            ),
            SIButton(label: "Register")
          ],
        ),
      ),
    );
  }
}
