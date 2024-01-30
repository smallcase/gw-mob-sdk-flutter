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

  TextEditingController _searchController = TextEditingController();

  void _onSearchTextChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(milliseconds: 500), () async {
      searchResults = await smartInvesting.stockSearch(value.toUpperCase());
      setState(() {});
    });
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
            TextField(
              controller: _searchController,
              decoration: InputDecoration(hintText: "Enter Ticker"),
              onChanged: _onSearchTextChanged,
            ),
            if (searchResults.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: searchResults
                      .map(
                        (result) => ListTile(
                          title: Text(result),
                          onTap: () {
                            setState(() {
                              securities = result;
                              _searchController.text = result;
                              searchResults
                                  .clear(); 
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
              ),
          ],
        ),
        SIButton(
          label: "PLACE ORDER",
          onPressed: () {
            print("AD:: BUTTON PRESSSED");
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
              print(orderConfig);
              repository.triggerTransaction(
                  ScgatewayIntent.TRANSACTION, orderConfig, false, context);
            } else {
              print("AD:: ELSE STATEMENT RUNNING");
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