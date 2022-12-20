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
  String notes;
  var startDate = "";
  var transactionIdForPostback = "";

  Future<void> importMfHoldings(String transactionId) async {
    try {
      final res = await ScgatewayFlutterPlugin.triggerMfGatewayTransaction(
          transactionId);
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
          TextField(decoration: InputDecoration(hintText: "Enter Notes"), onChanged: (value) => notes = value),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: TextField(
                    decoration: InputDecoration(hintText: "01-Aug-2022"),
                    onChanged: (value) => startDate = value),
              ),
              ElevatedButton(
                  onPressed: () async {
                    final intent = ScgatewayIntent.MF_HOLDINGS_IMPORT;
                    final assetConfig =
                        startDate.isEmpty ? null : {"fromDate": startDate};
                    final transactionId = await Gateway.getTransactionId(
                        intent, null,
                        assetConfig: assetConfig, notes: notes);
                    importMfHoldings(transactionId);
                  },
                  child: Text("Import Holdings"))
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
              child: Text("Search Postback")),
          ElevatedButton(
              onPressed: () {
                importMfHoldings(transactionIdForPostback);
              },
              child: Text("Trigger MF Transaction"))
        ],
      )),
    );
  }
}
