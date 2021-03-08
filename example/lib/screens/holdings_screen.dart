import 'package:clipboard_manager/clipboard_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:scgateway_flutter_plugin/scgateway_flutter_plugin.dart';
import 'package:scgateway_flutter_plugin_example/gateway.dart';

class HoldingsScreen extends StatefulWidget {

  HoldingsScreen({Key key}) : super(key: key);

  @override
  _HoldingsScreenState createState() => _HoldingsScreenState();
}

class _HoldingsScreenState extends State<HoldingsScreen> {

  Future<void> _importHoldings() async {

    _startImportHolding(ScgatewayIntent.HOLDINGS, null);
  }

  Future<String> _startImportHolding(String intent, Object orderConfig) async {
    Gateway.getTransactionId(intent, orderConfig).then((value) => _showAlertDialog(value));
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
          ],
        ),
      ),
    );
  }
}
