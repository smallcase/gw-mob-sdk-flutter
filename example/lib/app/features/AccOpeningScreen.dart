import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:scgateway_flutter_plugin/scgateway_flutter_plugin.dart';
import 'package:scgateway_flutter_plugin_example/app/global/SmartInvestingAppRepository.dart';
import 'package:scgateway_flutter_plugin_example/app/widgets/SIButton.dart';
import 'package:scgateway_flutter_plugin_example/app/widgets/SISwitch.dart';
import 'package:scgateway_flutter_plugin_example/app/widgets/SIText.dart';
import 'package:scgateway_flutter_plugin_example/app/widgets/SITextField.dart';

class AccOpeningScreen extends StatefulWidget {
  const AccOpeningScreen({super.key});
  @override
  State<AccOpeningScreen> createState() => AccOpeningScreenState();
}

class AccOpeningScreenState extends State<AccOpeningScreen> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(8),
      children: [
        SIText.large(text: "LEAD GEN"),
        SITextField(
          hint: "Enter Name",
          onChanged: (value) {
            repository.leadgenUserName.add(value);
          },
        ),
        SITextField(
          hint: "Enter Email",
          onChanged: (value) {
            repository.leadgenUserEmail.add(value);
          },
        ),
        SITextField(
          hint: "Enter Contact",
          onChanged: (value) {
            repository.leadgenUserContact.add(value);
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            StreamBuilder<bool>(
                stream: repository.withLoginCTA,
                builder: (context, snapshot) {
                  final data = snapshot.data;
                  if (data == null) {
                    return const SizedBox();
                  }
                  return SISwitch(
                    label: "Show Login CTA",
                    isEnabled: data,
                    onChanged: (value) {
                      repository.withLoginCTA.value = value;
                    },
                  );
                }),
          ],
        ),
        SIButton(
          label: "LEAD GEN",
          onPressed: () async {
            final leadgenUserName = repository.leadgenUserName.value ?? "";
            final leadgenUserEmail = repository.leadgenUserEmail.value ?? "";
            final leadgenUserContact =
                repository.leadgenUserContact.value ?? "";

            if (repository.withLoginCTA.value) {
              Map<String, String>? utmParams;
              final response = await ScgatewayFlutterPlugin.triggerLeadGenWithLoginCta(
                  leadgenUserName, leadgenUserEmail, leadgenUserContact,
                  utmParams: utmParams,
                  showLoginCta: repository.withLoginCTA.value);
              repository.showAlertDialog(response.toString(), context);
            } else {
              final response = await ScgatewayFlutterPlugin.leadGenWithStatus(
                  leadgenUserName, leadgenUserEmail, leadgenUserContact);
              repository.showAlertDialog(response.toString(), context);
            }
          },
        ),
        SizedBox.square(dimension: 24),
        SIText.large(text: "LOGOUT"),
        SIButton(
          label: "LOGOUT",
          onPressed: () async {
            final response = await ScgatewayFlutterPlugin.logoutUser();
            repository.showAlertDialog(response.toString(), context);
          },
        ),
      ],
    );
  }
}
