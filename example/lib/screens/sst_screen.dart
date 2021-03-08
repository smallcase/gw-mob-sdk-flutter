import 'package:clipboard_manager/clipboard_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:scgateway_flutter_plugin/scgateway_flutter_plugin.dart';
import 'package:scgateway_flutter_plugin_example/gateway.dart';

class SstScreen extends StatefulWidget {

  SstScreen({Key key}) : super(key: key);

  @override
  _SstScreenState createState() => _SstScreenState();
}

class _SstScreenState extends State<SstScreen> {

  String _securities = "";

  Future<void> _placeOrder() async {

    // ScgatewayFlutterPlugin.placeOrder(_securities);
    // Gateway.placeOrder(_securities);

    if(_securities != "") {

      var tickers = _securities.split(',');

      print(tickers);

      var tickersList = [];

      for (var i = 0; i < tickers.length; i++) {
        tickersList.add({
          "ticker":tickers[i]
        });
      }

      var res = {"securities":tickersList,"type":"SECURITIES"};

      print(res);

      // triggerTransaction("transaction", res);
      // ScgatewayFlutterPlugin.getGatewayIntent("transaction")
      //     .then((value) =>
      //
      //     _startSst(value, res)
      // );

      _startSst(ScgatewayIntent.TRANSACTION, res);

    } else {
      // triggerTransaction(transactionId);
    }
  }

  Future<String> _startSst(String intent, Object orderConfig) async {

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

  //----------------------------------  WIDGETS -------------------------------------- //

  Widget inputSecurities() {
    return SizedBox(width: 300, height: 35,
        child: TextField(
            onChanged: (value) {
              setState(() {
                _securities = value;
              });
            },
            decoration: InputDecoration(
              filled: false,
              hintText: 'Enter Tickers',
              hintStyle: new TextStyle(
                fontSize: 20.0,
              ),
            )
        )
    );
  }

  Widget btnPlaceOrder() {
    return SizedBox(width: 300, height: 35, child: RaisedButton(
      onPressed: _placeOrder,
      child: const Text('Place Order', style: TextStyle(fontSize: 20)),
    ));    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SST'),
      ),
      body: SafeArea(

        child: ListView(

          padding: EdgeInsets.only(top: 10, left: 15, right: 10),

          children: <Widget>[
            FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.none,
              child: inputSecurities(),
            ),
            FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.none,
              child: btnPlaceOrder(),
            ),
          ],
        ),
      ),
    );
  }
}
