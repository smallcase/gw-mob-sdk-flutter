import 'dart:async';
import 'package:scgateway_flutter_plugin/scgateway_flutter_plugin.dart';
import 'package:scgateway_flutter_plugin_example/app/features/ConnectScreen.dart';
import 'package:scgateway_flutter_plugin_example/app/global/SmartInvestingAppRepository.dart';
import 'package:scgateway_flutter_plugin_example/app/widgets/SIButton.dart';
import 'package:scgateway_flutter_plugin_example/app/widgets/SIText.dart';
import 'package:flutter/material.dart';

class SstScreen extends StatefulWidget {
  SstScreen({super.key});
  @override
  State<SstScreen> createState() => _SstScreenState();
}

class _SstScreenState extends State<SstScreen> {
  String securities = "";
  List<String> searchResults = [];
  Timer? _debounceTimer;
  List<String> searchHistory = [];

  void _onSearchTextChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(milliseconds: 200), () async {
      searchResults = await smartInvesting.stockSearch(value.toUpperCase());
      setState(() {});
    });
  }

  Iterable<Widget> getHistoryList(SearchController controller) {
    return searchHistory.map(
      (String text) => ListTile(
        // leading: const Icon(Icons.history),
        title: Text(text),
        trailing: IconButton(
          icon: const Icon(Icons.call_missed),
          onPressed: () {
            controller.text = text;
            controller.selection =
                TextSelection.collapsed(offset: controller.text.length);
          },
        ),
      ),
    );
  }

  Iterable<Widget> getSuggestions(SearchController controller) {
    return searchResults.map(
      (String result) => ListTile(
        title: Text(result),
        onTap: () {
          controller.closeView(result);
          securities = result;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(8),
      children: [
        Text("SINGLE STOCK TXN"),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SearchAnchor.bar(
              barHintText: 'Enter Ticker',
              suggestionsBuilder:
                  (BuildContext context, SearchController controller) {
                _onSearchTextChanged(controller.text);
                if (controller.text.isEmpty) {
                  if (searchHistory.isNotEmpty) {
                    return getHistoryList(controller);
                  }
                  return <Widget>[
                    Center(
                        child: Text('No search history.',
                            style: TextStyle(color: Colors.black)))
                  ];
                }
                return getSuggestions(controller);
              },
            ),
          ],
        ),
        SIButton(
          label: "PLACE ORDER",
          onPressed: () {
            if (securities != "") {
              var tickers = securities.split(',');
              var tickersList = [];
              for (var i = 0; i < tickers.length; i++) {
                tickersList.add({"ticker": tickers[i].toUpperCase()});
              }
              var orderConfig = {
                "securities": tickersList,
                "type": "SECURITIES"
              };
              repository.triggerTransaction(
                  ScgatewayIntent.TRANSACTION, orderConfig, false, context);
            } else {
              repository.showAlertDialog("empty ticker field", context);
            }
          },
        ),
        SIText.large(text: "SHOW ORDERS"),
        SIButton(
          label: "SHOW ORDERS",
          onPressed: () {
            ScgatewayFlutterPlugin.showOrders().then(
                (value) => repository.showAlertDialog(value ?? "", context));
          },
        ),
      ],
    );
  }
}