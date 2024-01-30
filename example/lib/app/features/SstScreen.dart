import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:scgateway_flutter_plugin/scgateway_flutter_plugin.dart';
import 'package:scgateway_flutter_plugin_example/app/SIGatewayPage.dart';
import 'package:scgateway_flutter_plugin_example/app/features/ConnectScreen.dart';
import 'package:scgateway_flutter_plugin_example/app/widgets/SIButton.dart';
import 'package:scgateway_flutter_plugin_example/app/widgets/SIText.dart';
import 'package:scgateway_flutter_plugin_example/app/widgets/SITextField.dart';
import 'package:flutter/material.dart';

class SstScreen extends StatelessWidget {
  SstScreen({super.key});
  String securities = "";
  List<String> searchResults = [];

  Timer? _debounceTimer;

  void _onSearchTextChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(milliseconds: 500), () async {
      securities = value;
       searchResults = await smartInvesting.stockSearch(value.toUpperCase());
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(8),
      children: [
        SIText.large(text: "SINGLE STOCK TXN"),
        SITextField(
          hint: "Enter Ticker", onChanged: (value) {
            securities = value;
          },
          // onChanged: _onSearchTextChanged,
        ),
        SIButton(label: "PLACE ORDER", onPressed: () {
               if (securities != "") {
      var tickers = securities.split(',');
      var tickersList = [];
      for (var i = 0; i < tickers.length; i++) {
        tickersList.add({"ticker": tickers[i].toUpperCase()});
      }
      var orderConfig = {"securities": tickersList, "type": "SECURITIES"};
      print(orderConfig);
      repository.triggerTransaction(ScgatewayIntent.TRANSACTION, orderConfig, false, context);
    } else {
      repository.showAlertDialog("empty ticker field", context);
    }
        },
        ),
        SIText.large(text: "SHOW ORDERS"),
        SIButton(label: "SHOW ORDERS", onPressed: () {
          ScgatewayFlutterPlugin.showOrders().then((value) => repository.showAlertDialog(value ?? "", context));
        },),
          Column(
          children: searchResults.map((result) => Text(result)).toList(),
        ),
      ],
    );
  }
}



      
