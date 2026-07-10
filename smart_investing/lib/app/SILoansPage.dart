import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:scloans/sc_loan.dart';

import '../main.dart';
import 'global/SmartInvestingAppRepository.dart';
import 'widgets/SIButton.dart';
import 'widgets/SIEnvironmentController.dart';
import 'widgets/SISwitch.dart';
import 'widgets/SIText.dart';
import 'widgets/SITextField.dart';

class SILoansPage extends StatefulWidget {
  const SILoansPage({super.key});

  @override
  State<SILoansPage> createState() => _SILoansPageState();
}

class _SILoansPageState extends State<SILoansPage> {
  static const _colorSchemeLabels = ['None', 'Light', 'Dark', 'System'];
  static const _colorSchemeValues = <ScLoanColorScheme?>[
    null,
    ScLoanColorScheme.light,
    ScLoanColorScheme.dark,
    ScLoanColorScheme.system,
  ];

  int _colorSchemeIndex = 0;

  ScLoanInfo _buildLoanInfo() {
    final token = repository.scLoanConfig.value.customInteractionToken ?? "";
    final scheme = _colorSchemeValues[_colorSchemeIndex];
    return ScLoanInfo(token, colorScheme: scheme);
  }

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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SIText.large(text: "Color Scheme"),
                  const SizedBox(height: 6),
                  ToggleButtons(
                    isSelected: List.generate(
                      _colorSchemeLabels.length,
                      (i) => i == _colorSchemeIndex,
                    ),
                    onPressed: (i) => setState(() => _colorSchemeIndex = i),
                    borderRadius: BorderRadius.circular(8),
                    children: _colorSchemeLabels
                        .map((label) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 14),
                              child: Text(label),
                            ))
                        .toList(),
                  ),
                ],
              ),
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
                      final response = await ScLoan.apply(_buildLoanInfo());
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
                        final response = await ScLoan.pay(_buildLoanInfo());
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
                        final response =
                            await ScLoan.withdraw(_buildLoanInfo());
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
                        final response =
                            await ScLoan.service(_buildLoanInfo());
                        repository.showAlertDialog(
                            response.toString(), context);
                      } on ScLoanError catch (e) {
                        repository.showAlertDialog(e.toString(), context);
                      }
                    }),
                SIButton(
                    label: "Trigger Interaction",
                    onPressed: () async {
                      try {
                        final response =
                            await ScLoan.triggerInteraction(_buildLoanInfo());
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
