import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;

import 'dart:async';
import 'dart:convert';
import 'package:scgateway_flutter_plugin/scgateway_flutter_plugin.dart';

class ConnectScreen extends StatefulWidget {

  ConnectScreen({Key key}) : super(key: key);

  @override
  _ConnectScreenState createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {

  static const setupGateway = const MethodChannel('smartinvesting/setup');

  static const connectToBroker = const MethodChannel('smartinvesting/connect');

  TextEditingController _c;

  int _environmentSelected = 0;

  bool _leprechaunMode = true;
  bool _isAmoEnabled = true;

  String _baseUrl = "";

  String _userIdText = "";

  String _authToken = "";

  String _transactionId = "";

  Map<int, Widget> _environments = {
    0: Text('Prod'),
    1: Text('Dev'),
    2: Text('Staging')
  };

  @override
  initState(){
    _c = new TextEditingController();
    super.initState();
  }

  Future<void> _initSession() async {

      switch(_environmentSelected) {
        case 1: {
          _baseUrl = "https://api.dev.smartinvesting.io/";
        }
        break;

        case 2: {
          _baseUrl = "https://api.stag.smartinvesting.io/";
        }
        break;

        default: {
          _baseUrl = "https://api.smartinvesting.io/";
        }
        break;
      }

      ScgatewayFlutterPlugin.setGatewayEnvironment(_baseUrl, _userIdText, _environmentSelected, _leprechaunMode, _isAmoEnabled)
          .then((String setupResult) =>
                _showAlertDialog(setupResult.toString()));
  }

  Future<void> triggerTransaction(String gatewayIntent, Object orderConfig) async {

    ScgatewayFlutterPlugin.getTransactionId(gatewayIntent, orderConfig);

  }

  Future<void> _showAlertDialog(String message) async {
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
          ],
        );
      },
    );
  }

  Widget segmentedControl() {
    return Container(
      width: 200,
      padding: const EdgeInsets.only(left: 20),
      child: CupertinoSlidingSegmentedControl(
          groupValue: _environmentSelected,
          children: _environments,
          onValueChanged: (value) {
            setState(() {
              _environmentSelected = value;
            });
          }
      ),
    );
  }

  Widget environment() {
    return Row(
      children: <Widget>[
        Text('Environment'),
        segmentedControl()
      ],
    );
  }

  Widget gateway() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        SizedBox(height: 50),
        Text('Gateway '),
        SizedBox(width: 200, height: 30, child: TextField(decoration: InputDecoration(
              filled: true,
              labelText: 'gatewaydemo',
            ),
          ),
        )
      ],
    );
  }

  Widget userId() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text('Id '),
        SizedBox(width: 200, height: 30, child: TextField(decoration: InputDecoration(
          filled: true,
          labelText: '',
        ),
          onChanged: (id) {
            setState(() {
              _userIdText = id;
            });
          },
        ),
        )
      ],
    );
  }

  Widget leprechaun() {
    return Row(
      children: <Widget>[
        Text('Leprechaun Mode'),
        SizedBox(width: 60, height: 20, child: Switch(activeTrackColor: Colors.green, activeColor: Colors.green, value: _leprechaunMode, onChanged: (value) {
          setState(() {
            _leprechaunMode = value;
          });
        }))
      ],
    );
  }

  Widget amo() {
    return Row(
      children: <Widget>[
        Text('AMO Mode'),
        SizedBox(width: 60, height: 20, child: Switch(activeTrackColor: Colors.green, activeColor: Colors.green, value: _isAmoEnabled, onChanged: (value) {
          setState(() {
            _isAmoEnabled = value;
          });
        }))
      ],
    );
  }

  Widget setup() {
    return SizedBox(width: 300, height: 35, child: RaisedButton(
          onPressed: _initSession,
          child: const Text('Setup', style: TextStyle(fontSize: 20)),
        ));
  }

  Widget connect() {
    return SizedBox(width: 300, height: 35, child: RaisedButton(
      onPressed: () {
        triggerTransaction("connect", null);
      },
      child: const Text('Connect', style: TextStyle(fontSize: 20)),
    ));
  }

  Widget enterTransactionId() {
    return SizedBox(width: 300, height: 35, child:
    RaisedButton(
      onPressed: () {
        showDialog(
            child: new Dialog(
                  child: SizedBox(
                    width: 300, height: 96,
                    child: new Column(
                        children: <Widget>[
                          new TextField(
                            decoration: new InputDecoration(hintText: "Enter Transaction Id"),
                            controller: _c,
                          ),
                          new FlatButton(
                            child: new Text("Save"),
                              onPressed: () {
                                setState((){
                                  this._transactionId = _c.text;
                                });
                                Navigator.pop(context);
                              },
                          )
                        ],
                    )
                  )
                // child: new Column(
                //     children: <Widget>[
                //       new TextField(
                //         decoration: new InputDecoration(hintText: "Enter Transaction Id"),
                //         controller: _c,
                //       ),
                //       new FlatButton(
                //         child: new Text("Save"),
                //           onPressed: () {
                //             setState((){
                //               this._transactionId = _c.text;
                //             });
                //             Navigator.pop(context);
                //           },
                //       )
                //     ],
                // )
            ), context: context);
      },
      child: const Text('Enter Transaction Id', style: TextStyle(fontSize: 20)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Connect'),
      ),
      body: SafeArea(

        child: ListView(

          padding: EdgeInsets.only(top: 10, left: 15, right: 10),

          children: <Widget>[
            FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.none,
              child: environment(),
            ),
            FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.none,
              child: gateway(),
            ),
            FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.none,
              child: userId(),
            ),
            FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.none,
              child: leprechaun(),
            ),
            FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.none,
              child: amo(),
            ),
            FittedBox(
              alignment: Alignment.center,
              fit: BoxFit.none,
              child: setup(),
            ),
            FittedBox(
              alignment: Alignment.center,
              fit: BoxFit.none,
              child: connect(),
            ),
            FittedBox(
              alignment: Alignment.center,
              fit: BoxFit.none,
              child: enterTransactionId(),
            )
          ],
        ),
      ),
    );
  }
}
