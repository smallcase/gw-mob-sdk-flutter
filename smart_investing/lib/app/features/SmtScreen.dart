import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:scgateway_flutter_plugin/scgateway_flutter_plugin.dart';

import '../global/SmartInvestingAppRepository.dart';
import '../widgets/SIButton.dart';
import '../widgets/SIText.dart';
import '../widgets/SITextField.dart';
import 'SmallcaseList.dart';
import 'subscreens/InvestmentsList.dart';

class SmtScreen extends StatefulWidget {
  const SmtScreen({super.key});

  @override
  State<SmtScreen> createState() => SmtScreenState();
}

class SmtScreenState extends State<SmtScreen> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(8),
      children: [
        SIText.large(text: "INVESTMENTS"),
        Wrap(
          children: [
            SIButton(
              label: "SMALLCASES",
              onPressed: () async {
                ScgatewayFlutterPlugin.getAllSmallcases().then((initResponse) {
                  final Map<String, dynamic> responseData =
                      jsonDecode(initResponse ?? "");
                  var list = responseData['data']['smallcases'] as List;
                  if (list.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SmallcasesList(
                          items: responseData['data']['smallcases'],
                        ),
                      ),
                    );
                  } else {}
                });
              },
            ),
            SIButton(
                label: "USER INVESTMENTS",
                onPressed: () async {
                  ScgatewayFlutterPlugin.getAllUserInvestments()
                      .then((initResponse) {
                    final Map<String, dynamic> responseData = jsonDecode(initResponse ?? "");
                    var investments = responseData['data'] as List;
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              InvestmentsList(investments: investments),
                        ));
                  });
                }),
            SIButton(
              label: "EXITED SMALLCASES",
              onPressed: () async {
                final response = await ScgatewayFlutterPlugin.getAllExitedSmallcases();
                repository.showAlertDialog(response.toString(), context);
              },
            ),
          ],
        ),
        SIText.large(text: "WEALTH MODULE"),
        SITextField(
          hint: "Endpoint",
          onChanged: (value) {
            repository.smallplugEndpoint.add(value);
          },
        ),
        Row(children: [
          Flexible(
            child: SITextField(
              hint: "Header Color",
              onChanged: (value) {
                repository.headerColor.add(value);
              },
            ),
          ),
          SizedBox.square(dimension: 8),
          Flexible(
            child: SITextField(
              hint: "Header Opacity",
              onChanged: (value) {
                repository.headerOpacity.add(double.parse(value));
              },
            ),
          ),
        ]),
        Row(
          children: [
            Flexible(
              child: SITextField(
                hint: "Back Icon Color",
                onChanged: (value) {
                  repository.backIconColor.add(value);
                },
              ),
            ),
            SizedBox.square(dimension: 8),
            Flexible(
              child: SITextField(
                hint: "Back Icon Opacity",
                onChanged: (value) {
                  repository.backIconOpacity.add(double.parse(value));
                },
              ),
            ),
          ],
        ),
        SIButton(
            label: "SMALLPLUG",
            onPressed: () async {
              SmallplugData smallplugData = new SmallplugData();
              final hc = repository.headerColor.value == null
                  ? null
                  : repository
                      .getColorFromHex(repository.headerColor.value ?? "");
              final bc = repository.backIconColor.value == null
                  ? null
                  : repository
                      .getColorFromHex(repository.backIconColor.value ?? "");
              SmallplugUiConfig smallplugUiConfig = new SmallplugUiConfig(
                  headerColor: hc,
                  backIconColor: bc,
                  headerOpacity: repository.headerOpacity.value ?? 1,
                  backIconOpacity: repository.backIconOpacity.value ?? 1);

              if (repository.smallplugEndpoint.value != null &&
                  repository.smallplugEndpoint.value != "") {
                smallplugData.targetEndpoint =
                    repository.smallplugEndpoint.value;
              }

              final initResponse =
                  await ScgatewayFlutterPlugin.launchSmallplugWithBranding(
                      smallplugData,
                      smallplugUiConfig: smallplugUiConfig);
              repository.showAlertDialog(initResponse.toString(), context);
            })
      ],
    );
  }
}
