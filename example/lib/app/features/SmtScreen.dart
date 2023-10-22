import 'package:flutter/widgets.dart';
import 'package:scgateway_flutter_plugin_example/app/widgets/SIButton.dart';
import 'package:scgateway_flutter_plugin_example/app/widgets/SIText.dart';
import 'package:scgateway_flutter_plugin_example/app/widgets/SITextField.dart';

class SmtScreen extends StatelessWidget {
  const SmtScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(8),
      children: [
        SIText.large(text: "INVESTMENTS"),
        Wrap(
          children: [
            SIButton(label: "SMALLCASES"),
            SIButton(label: "USER INVESTMENTS"),
            SIButton(label: "EXITED SMALLCASES"),
          ],
        ),
        SIText.large(text: "WEALTH MODULE"),
        SITextField(hint: "Endpoint"),
        Row(children: [
          Flexible(
            child: SITextField(hint: "Header Color"),
          ),
          SizedBox.square(dimension: 8),
          Flexible(
            child: SITextField(hint: "Header Opacity"),
          ),
        ]),
        Row(
          children: [
            Flexible(
              child: SITextField(hint: "Back Icon Color"),
            ),
            SizedBox.square(dimension: 8),
            Flexible(
              child: SITextField(hint: "Back Icon Opacity"),
            ),
          ],
        ),
        SIButton(label: "SMALLPLUG")
      ],
    );
  }
}
