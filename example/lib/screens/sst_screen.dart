import 'package:clipboard/clipboard.dart';
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

    if (_securities != "") {
      var tickers = _securities.split(',');

      print(tickers);

      var tickersList = [];

      for (var i = 0; i < tickers.length; i++) {
        tickersList.add({"ticker": tickers[i]});
      }

      var res = {"securities": tickersList, "type": "SECURITIES"};

      print(res);

      _startSst(ScgatewayIntent.TRANSACTION, res);
    } else {
      // triggerTransaction(transactionId);
    }
  }

  Future<String> _startSst(String intent, Object orderConfig) async {
    Gateway.getTransactionIdAndStartTxn(intent, orderConfig)
        .then((value) => _showAlertDialog(value));
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

  //----------------------------------  WIDGETS -------------------------------------- //

  Widget inputSecurities() {
    return SizedBox(
        width: 300,
        height: 35,
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
            )));
  }

  Widget btnPlaceOrder() {
    return SizedBox(
        width: 300,
        height: 35,
        child: RaisedButton(
          onPressed: _placeOrder,
          child: const Text('Place Order', style: TextStyle(fontSize: 20)),
        ));
  }

  Widget _btnShowOrders() {
    return SizedBox(
      width: 300,
      child: ElevatedButton(
          onPressed: () {
            Gateway.showOrders().then((value) => _showAlertDialog(value));
          },
          child: Text('Show Orders')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SST'),
      ),
      body: SafeArea(
        child: Container(
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 20,
              ),
              inputSecurities(),
              SizedBox(
                height: 20,
              ),
              btnPlaceOrder(),
              SizedBox(
                height: 20,
              ),
              _btnShowOrders()
            ],
          ),
        ),
      ),
    );
  }
}
