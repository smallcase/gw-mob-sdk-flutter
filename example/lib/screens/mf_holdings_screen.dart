import 'package:flutter/material.dart';
import 'package:scgateway_flutter_plugin/scgateway_flutter_plugin.dart';
import 'package:scgateway_flutter_plugin_example/extensions.dart';
import 'package:scgateway_flutter_plugin_example/gateway.dart';

class MFHoldingsScreen extends StatefulWidget {
  const MFHoldingsScreen({Key key}) : super(key: key);

  @override
  State<MFHoldingsScreen> createState() => _MFHoldingsScreenState();
}

class _MFHoldingsScreenState extends State<MFHoldingsScreen> {
  var startDate = "";
  var endDate = "";
  var transactionIdForPostback = "";

  Future<void> importMfHoldings() async {
    try {
      final intent = ScgatewayIntent.MF_HOLDINGS_IMPORT;
      final assetConfig = {"fromDate": startDate, "toDate": endDate};
      final transactionId = await Gateway.getTransactionId(intent, null,
          assetConfig: assetConfig);
      final res =
          await ScgatewayFlutterPlugin.triggerMfGatewayTransaction(transactionId);
      await context.showScDialog("$res");
      getMfHoldings(transactionId);
    } catch (e) {
      context.showScDialog("$e");
    }
  }

  Future<void> getMfHoldings(String transactionId) async {
    try {
      final response = await Gateway.getMfHoldings(transactionId);
      await context.showScDialog("$response");
    } catch (e) {
      context.showScDialog("$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: TextField(
                    decoration: InputDecoration(hintText: "Start Date"),
                    onChanged: (value) => startDate = value),
              ),
              Flexible(
                child: TextField(
                    decoration: InputDecoration(hintText: "End Date"),
                    onChanged: (value) => endDate = value),
              ),
              ElevatedButton(
                  onPressed: importMfHoldings, child: Text("Import Holdings"))
            ],
          ),
          TextField(
            decoration: InputDecoration(hintText: "Enter Transaction Id"),
            onChanged: (value) => transactionIdForPostback = value,
          ),
          ElevatedButton(
              onPressed: () {
                getMfHoldings(transactionIdForPostback);
              },
              child: Text("Search Postback"))
        ],
      )),
    );
  }
}
