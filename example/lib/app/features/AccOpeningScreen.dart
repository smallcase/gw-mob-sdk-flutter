import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:scgateway_flutter_plugin_example/app/widgets/SIButton.dart';
import 'package:scgateway_flutter_plugin_example/app/widgets/SIText.dart';
import 'package:scgateway_flutter_plugin_example/app/widgets/SITextField.dart';

class AccOpeningScreen extends StatelessWidget {
  const AccOpeningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(8),
      children: [
        SIText.large(text: "LEAD GEN"),
        SITextField(hint: "Enter Name"),
        SITextField(hint: "Enter Email"),
        SITextField(hint: "Enter Contact"),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SIText(text: "Show Login CTA"),
            Switch.adaptive(
              value: true,
              onChanged: (value) {},
            )
          ],
        ),
        SIButton(label: "LEAD GEN"),
        SizedBox.square(dimension: 24),
        SIText.large(text: "LOGOUT"),
        SIButton(label: "LOGOUT"),
      ],
    );
  }
}
