import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:scgateway_flutter_plugin/scgateway_flutter_plugin.dart';

class HoldingsScreen extends StatefulWidget {

  HoldingsScreen({Key key}) : super(key: key);

  @override
  _HoldingsScreenState createState() => _HoldingsScreenState();
}

class _HoldingsScreenState extends State<HoldingsScreen> {

  Future<void> _importHoldings() async {

    ScgatewayFlutterPlugin.importHoldings();

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
