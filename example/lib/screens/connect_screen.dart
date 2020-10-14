import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;

import 'dart:async';
import 'dart:convert';

class ConnectScreen extends StatefulWidget {

  ConnectScreen({Key key}) : super(key: key);

  @override
  _ConnectScreenState createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {

  static const setupGateway = const MethodChannel('smartinvesting/setup');

  static const connectToBroker = const MethodChannel('smartinvesting/connect');

  int _currentSelection = 0;

  bool _leprechaunMode = true;
  bool _isAmoEnabled = true;

  String _baseUrl = "";

  String _userIdText = "";

  String _authToken = "";

  String _transactionId = "";

  Map<int, Widget> _children = {
    0: Text('Prod'),
    1: Text('Dev'),
    2: Text('Staging')
  };

  Future<void> _initSession() async {

      switch(_currentSelection) {
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

      getSessionToken(_baseUrl, _userIdText);
  }

  Future<void> _initGateway() async {
    String initGatewayResult;

    try{
      initGatewayResult = await setupGateway.invokeMethod(
          'initializeGateway',
          <String, dynamic>{"env": _currentSelection, "gateway": "gatewaydemo", "userId": _userIdText, "leprechaun": _leprechaunMode, "amo": _isAmoEnabled, "authToken": _authToken});
      print(initGatewayResult);
    } on PlatformException catch (e) {
      initGatewayResult = "Failed to get result: ' ${e.message}'";
    }
  }

  Future<void> getSessionToken(String baseUrl, String idText) async {
    final http.Response response = await http.post(
      baseUrl + 'user/login',

      headers: <String, String>{
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, GET, OPTIONS, PUT',
        'Accept': 'application/json',
        'content-type': 'application/x-www-form-urlencoded'
      },

      body: jsonEncode(<String, String>{
        'id': _userIdText,
      }),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      var connected = data["connected"] as bool;

      setState(() {
        _authToken = data["smallcaseAuthToken"] as String;
      });

      _showAlertDialog('authToken: ' + _authToken, 'connected: ' + connected.toString() );

      print(connected);
      print(_authToken);

      _initGateway();

      // return AppAuthDTO.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get session token.');
    }
  }

  Future<void> _getTransactionId(String gatewayIntent, Object orderConfig) async {

    String connectGatewayResult;

    try {
      connectGatewayResult = await connectToBroker.invokeMethod(
        'getTransactionId', <String, dynamic>{"intent": gatewayIntent}
      );
      print(connectGatewayResult);
    } on PlatformException catch (e) {
      connectGatewayResult = "Failed to get result: ' ${e.message}'";
    }

    Map data = {
      'id': _userIdText,
      'intent': connectGatewayResult,
      'orderConfig': null
    };

    String bodyData = json.encode(data);

    final http.Response response = await http.post(
      _baseUrl + 'transaction/new',

      headers: <String, String>{
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, GET, OPTIONS, PUT',
        'Accept': 'application/json',
        'content-type':'application/json'
      },

      body: bodyData,
    );

    print(response.body);

    if (response.statusCode == 200) {
      var connectData = jsonDecode(response.body);

      var txnId = connectData["transactionId"] as String;

      setState(() {
        // _transactionId = connectData["transactionId"] as String;
        _transactionId = txnId;
      });

      _triggerGatewayTransaction(txnId);

    } else {
      throw Exception('Failed to get session token.');
    }
  }

  Future<void> _triggerGatewayTransaction(String txnId) async{

    String triggerTxnRes;

    try {
      triggerTxnRes = await connectToBroker.invokeMethod(
          'connectToBroker', <String, dynamic>{"transactionId": txnId}
      );
      print(triggerTxnRes);
    } on PlatformException catch (e) {
      triggerTxnRes = "Failed to get result: ' ${e.message}'";
    }

  }

  Future<void> _showAlertDialog(String title, String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Gateway'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(title),
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
          groupValue: _currentSelection,
          children: _children,
          onValueChanged: (value) {
            setState(() {
              _currentSelection = value;
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
        _getTransactionId("connect", null);
      },
      child: const Text('Connect', style: TextStyle(fontSize: 20)),
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
            )
          ],
        ),
      ),
    );
  }
}
