import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:scgateway_flutter_plugin/scgateway_flutter_plugin.dart';
import 'package:scgateway_flutter_plugin_example/gateway.dart';
import 'package:scgateway_flutter_plugin_example/models/UserHoldingsResponse.dart';
import 'package:scgateway_flutter_plugin_example/screens/UserHoldingsScreen.dart';
import 'package:scgateway_flutter_plugin_example/screens/mf_holdings_screen.dart';

class HoldingsScreen extends StatefulWidget {
  HoldingsScreen({Key key}) : super(key: key);

  @override
  _HoldingsScreenState createState() => _HoldingsScreenState();
}

class _HoldingsScreenState extends State<HoldingsScreen> {
  bool v2 = false;
  bool mfEnabled = false;

  Future<void> _importHoldings() async {
    _startHoldingsTransactionFor(ScgatewayIntent.HOLDINGS, null);
  }

  Future<void> _fetchFunds() async {
    _startHoldingsTransactionFor(ScgatewayIntent.FETCH_FUNDS, null);
  }

  Future<void> _authoriseHoldings() async {
    _startHoldingsTransactionFor(ScgatewayIntent.AUTHORISE_HOLDINGS, null);
  }

  Future<void> _startHoldingsTransactionFor(
      String intent, Object orderConfig) async {
    Gateway.getTransactionIdAndStartTxn(intent, orderConfig)
        .then((value) => _showAlertDialog(value));
  }

  Future<void> _getUserHoldings() async {
    // Gateway.getUserHoldings().then((value) => _showAlertDialog(value.data.data.securities.holdings[0].ticker));
    Gateway.getUserHoldings(version: v2 ? 2 : 1, mfEnabled: mfEnabled)
        .then((value) => _showUserHoldings(context, value));
  }

  void _showUserHoldings(
      BuildContext context, UserHoldingsResponse holdings) async {
    print("holdings : $holdings");

    await _showAlertDialog(holdings.toString());

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserHoldingsScreen(holdings: holdings),
        ));
  }

  Future<void> _showAlertDialog(String message) async {
    // FlutterClipboard.copy(message);

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Gateway'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[Text(message)],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
                onPressed: () {
                  FlutterClipboard.copy(message);
                },
                child: Text('Copy'))
          ],
        );
      },
    );
  }

  Widget btnImportHoldings() {
    return SizedBox(
        width: 300,
        height: 35,
        child: ElevatedButton(
          onPressed: _importHoldings,
          child: const Text('Import Holdings', style: TextStyle(fontSize: 20)),
        ));
  }

  Widget btnFetchFunds() {
    return SizedBox(
        width: 300,
        height: 35,
        child: ElevatedButton(
          onPressed: _fetchFunds,
          child: const Text('Fetch Funds', style: TextStyle(fontSize: 20)),
        ));
  }

  Widget btnAuthorizeHoldings() {
    return SizedBox(
        width: 300,
        height: 35,
        child: ElevatedButton(
          onPressed: _authoriseHoldings,
          child:
              const Text('Authorize Holdings', style: TextStyle(fontSize: 20)),
        ));
  }

  Widget btnShowUserHoldings() {
    return SizedBox(
        width: 300,
        height: 35,
        child: ElevatedButton(
          onPressed: _getUserHoldings,
          child: const Text('Show Holdings', style: TextStyle(fontSize: 20)),
        ));
  }

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ToggleBtn(
                label: 'Enable v2',
                value: v2,
                onChanged: (value) => setState(() {
                  v2 = !v2;
                }),
              ),
              ToggleBtn(
                label: 'Enable MF',
                value: mfEnabled,
                onChanged: (value) => setState(() {
                  mfEnabled = !mfEnabled;
                }),
              ),
            ],
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (ct) => MFHoldingsScreen()));
              },
              child: Text("MF Holdings")),
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
      )),
    );
  }
}

class ToggleBtn extends StatelessWidget {
  final String label;
  final bool value;
  final Function(bool value) onChanged;
  const ToggleBtn({Key key, this.label, this.value, this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
