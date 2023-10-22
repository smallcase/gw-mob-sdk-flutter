import 'package:flutter/widgets.dart';
import 'package:scgateway_flutter_plugin_example/app/widgets/SIButton.dart';
import 'package:scgateway_flutter_plugin_example/app/widgets/SIText.dart';
import 'package:scgateway_flutter_plugin_example/app/widgets/SITextField.dart';

class SstScreen extends StatelessWidget {
  const SstScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(8),
      children: [
        SIText.large(text: "SINGLE STOCK TXN"),
        SITextField(
          hint: "Enter Ticker",
        ),
        SIButton(label: "PLACE ORDER"),
        SIText.large(text: "SHOW ORDERS"),
        SIButton(label: "SHOW ORDERS"),
      ],
    );
  }
}
