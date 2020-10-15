import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:scgateway_flutter_plugin/scgateway_flutter_plugin.dart';

class SstScreen extends StatefulWidget {

  SstScreen({Key key}) : super(key: key);

  @override
  _SstScreenState createState() => _SstScreenState();
}

class _SstScreenState extends State<SstScreen> {

  String _securities = "";

  Future<void> _placeOrder() async {

    ScgatewayFlutterPlugin.placeOrder(_securities);

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
