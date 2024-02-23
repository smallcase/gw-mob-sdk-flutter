import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:scgateway_flutter_plugin/scgateway_flutter_plugin.dart';
import 'package:scgateway_flutter_plugin_example/app/models/SmallcaseDTO.dart';
import 'package:scgateway_flutter_plugin_example/app/models/SmallcaseInfoDTO.dart';
import 'package:scgateway_flutter_plugin_example/app/models/SmallcaseList.dart';
import 'package:scgateway_flutter_plugin_example/app/global/SmartInvestingAppRepository.dart';
import 'package:scgateway_flutter_plugin_example/app/models/SmallcaseStatsDTO.dart';
import 'package:scgateway_flutter_plugin_example/app/widgets/SIButton.dart';
import 'package:scgateway_flutter_plugin_example/app/widgets/SIText.dart';
import 'package:scgateway_flutter_plugin_example/app/widgets/SITextField.dart';

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
                  List<SmallcasesDTO> smallcases =
                      list.map((i) => SmallcasesDTO.fromJson(i)).toList();
                  setState(() {
                    repository.smallcaseItems.value = smallcases;
                  });
                  if (smallcases.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SmallcasesList(
                          items: repository.smallcaseItems.value,
                        ),
                      ),
                    );
                  } else {
                  }
                });
              },
            ),
            SIButton(
                label: "USER INVESTMENTS",
                onPressed: () async {
                  ScgatewayFlutterPlugin.getAllUserInvestments();
                }),
            SIButton(
              label: "EXITED SMALLCASES",
              onPressed: () async {
                ScgatewayFlutterPlugin.getAllExitedSmallcases();
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
              debugPrint("hc: $hc");
              SmallplugUiConfig smallplugUiConfig = new SmallplugUiConfig(
                  headerColor: hc,
                  backIconColor: bc,
                  headerOpacity: repository.headerOpacity.value ?? 0,
                  backIconOpacity: repository.backIconOpacity.value ?? 0);

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
