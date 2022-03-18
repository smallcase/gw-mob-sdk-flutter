import 'package:clipboard_manager/clipboard_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:scgateway_flutter_plugin/scgateway_flutter_plugin.dart';
import 'package:scgateway_flutter_plugin_example/gateway.dart';
import 'package:scgateway_flutter_plugin_example/models/UserHoldingsResponse.dart';
import 'package:scgateway_flutter_plugin_example/screens/UserHoldingsScreen.dart';

class HoldingsScreen extends StatefulWidget {

  HoldingsScreen({Key key}) : super(key: key);

  @override
  _HoldingsScreenState createState() => _HoldingsScreenState();
}

class _HoldingsScreenState extends State<HoldingsScreen> {

  Future<void> _importHoldings() async {
    _startHoldingsTransactionFor(ScgatewayIntent.HOLDINGS, null);
  }

  Future<void> _fetchFunds() async {
    _startHoldingsTransactionFor(ScgatewayIntent.FETCH_FUNDS, null);
  }

  Future<void> _authoriseHoldings() async {
    _startHoldingsTransactionFor(ScgatewayIntent.AUTHORISE_HOLDINGS, null);
  }

  Future<void> _startHoldingsTransactionFor(String intent, Object orderConfig) async {
    Gateway.getTransactionId(intent, orderConfig).then((value) => _showAlertDialog(value));
  }

  Future<void> _getUserHoldings() async {

    // Gateway.getUserHoldings().then((value) => _showAlertDialog(value.data.data.securities.holdings[0].ticker));
    Gateway.getUserHoldings().then((value) => _showUserHoldings(context, value));
  }

  void _showUserHoldings(BuildContext context, UserHoldingsResponse holdings) {

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserHoldingsScreen(holdings: holdings),
    ));
  }

  Future<void> _showAlertDialog(String message) async {

    // ClipboardManager.copyToClipBoard(message);

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Gateway'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message)
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(onPressed: () {
              ClipboardManager.copyToClipBoard(message);
            }, child: Text('Copy')
            )
          ],
        );
      },
    );
  }

  Widget btnImportHoldings() {
    return SizedBox(width: 300, height: 35, child: RaisedButton(
      onPressed: _importHoldings,
      child: const Text('Import Holdings', style: TextStyle(fontSize: 20)),
    ));
  }

  Widget btnFetchFunds() {
    return SizedBox(width: 300, height: 35, child: RaisedButton(
      onPressed: _fetchFunds,
      child: const Text('Fetch Funds', style: TextStyle(fontSize: 20)),
    ));
  }

  Widget btnAuthorizeHoldings() {
    return SizedBox(width: 300, height: 35, child: RaisedButton(
      onPressed: _authoriseHoldings,
      child: const Text('Authorize Holdings', style: TextStyle(fontSize: 20)),
    ));
  }

  Widget btnShowUserHoldings() {
    return SizedBox(width: 300, height: 35, child: RaisedButton(
      onPressed: _getUserHoldings,
      child: const Text('Show Holdings', style: TextStyle(fontSize: 20)),
    ));
  }

  // final List<String> entries = <String>['A', 'B', 'C','A', 'B', 'C','A', 'B', 'C','A', 'B', 'C','A', 'B', 'C','A', 'B', 'C'];
  // final List<int> colorCodes = <int>[600, 500, 100];
  //
  // Widget listUserHoldings() {
  //   return ListView.builder(
  //       padding: const EdgeInsets.all(8),
  //       itemCount: entries.length,
  //       itemBuilder: (BuildContext context, int index) {
  //         return Container(
  //           height: 50,
  //           color: Colors.amber[colorCodes[index]],
  //           child: Center(child: Text('Entry ${entries[index]}')),
  //         );
  //       }
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Holdings'),
      ),
      body: SafeArea(

        child: ListView(

          padding: EdgeInsets.only(top: 10, left: 15, right: 10),

          children: <Widget>[
            FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.none,
              child: btnImportHoldings(),
            ),
            FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.none,
              child: btnFetchFunds(),
            ),
            FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.none,
              child: btnAuthorizeHoldings(),
            ),
            FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.none,
              child: btnShowUserHoldings(),
            ),
          ],
        )
      ),
    );
  }
}
