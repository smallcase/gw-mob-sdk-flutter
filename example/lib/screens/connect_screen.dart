import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;

import 'dart:async';
import 'dart:convert';
import 'package:clipboard_manager/clipboard_manager.dart';

import 'package:scgateway_flutter_plugin/scgateway_flutter_plugin.dart';
import 'package:scgateway_flutter_plugin_example/gateway.dart';

class ConnectScreen extends StatefulWidget {

  ConnectScreen({Key key}) : super(key: key);

  @override
  _ConnectScreenState createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {

  TextEditingController _textEditingController;

  int _environmentSelected = 0;

  bool _leprechaunMode = true;
  bool _isAmoEnabled = true;

  String _baseUrl = "";

  String _userIdText = "";

  // String _authToken = "";

  String _transactionId = "";

  Map<int, Widget> _environments = {
    0: Text('Prod'),
    1: Text('Dev'),
    2: Text('Staging')
  };

  @override
  initState(){
    super.initState();
    _userIdText = PageStorage
        .of(context)
        ?.readState(context, identifier: ValueKey('test'));
    _textEditingController = new TextEditingController(text: _userIdText);
    _environmentSelected = PageStorage
        .of(context)
        ?.readState(context, identifier: ValueKey('selectedEnv'));
    _transactionId = PageStorage
        .of(context)
        ?.readState(context, identifier: ValueKey('txnId'));
  }

  Future<void> _initSession() async {
    
    GatewayEnvironment enviroment;

      switch(_environmentSelected) {
        case 1: {
          _baseUrl = "https://api.dev.smartinvesting.io/";
          enviroment = GatewayEnvironment.DEVELOPMENT;
        }
        break;

        case 2: {
          _baseUrl = "https://api.stag.smartinvesting.io/";
          enviroment = GatewayEnvironment.STAGING;
        }
        break;

        default: {
          _baseUrl = "https://api.smartinvesting.io/";
          enviroment = GatewayEnvironment.PRODUCTION;
        }
        break;
      }

      List<String> brokers = ['kite','hdfc','iifl'];

      ScgatewayFlutterPlugin.setConfigEnvironment(enviroment, "gatewaydemo", _leprechaunMode, brokers, isAmoenabled: _isAmoEnabled).then((setupResponse) =>

          Gateway.getSessionToken(_baseUrl, _userIdText, enviroment, _leprechaunMode, _isAmoEnabled).then((value) => _showAlertDialog(value))
      );

      // Gateway.getSessionToken(_baseUrl, _userIdText, enviroment, _leprechaunMode, _isAmoEnabled).then((value) => _showAlertDialog(value));
  }
  
  Future<void> _getTransactionId(String intent, Object orderConfig) async {

    Gateway.getTransactionId(intent, orderConfig).then((value) => _onUserConnected(value));
  }

   Future<void> _onUserConnected(String initResponse) async {

    print("transaction auth token: $initResponse");

    final Map<String, dynamic> responseData = jsonDecode(initResponse);

    print("ResponseData = $responseData");

    var authToken = responseData['data'] as String;

    print("auth token = $authToken");

      if(Gateway.transactionId.isNotEmpty) {
        setState((){
          this._transactionId = Gateway.transactionId;
          PageStorage.of(context)?.writeState(
              context, this._transactionId,
              identifier: ValueKey('txnId'));
        });
      }

     _showAlertDialog(initResponse);

    Map data = {
      'id': _userIdText,
      'smallcaseAuthToken': authToken
    };

    String bodyData = json.encode(data);

    print("On User connected body: $data");

    final http.Response response = await http.post(
        Gateway.baseURL + 'user/connect',

        headers: <String, String>{
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'POST, GET, OPTIONS, PUT',
          'Accept': 'application/json',
          'content-type':'application/json'
        },

        body: bodyData
    );

    print("On user Connect: ");
    print(response.body);
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
            },
                child: Text('Copy')
            )
          ],
        );
      },
    );
  }

  //----------------------------------  WIDGETS -------------------------------------- //
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
              PageStorage.of(context)?.writeState(
                  context, value,
                  identifier: ValueKey('selectedEnv'));
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

  String getUserIdText() {
    if(_userIdText != null) {
      return _userIdText;
    } else {
      return '';
    }
  }

  Widget userId() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text('Id '),
        SizedBox(width: 200, height: 30, child: TextField(decoration: InputDecoration(
          filled: true,
          labelText: getUserIdText(),
        ),
          onChanged: (id) {
            setState(() {
              _userIdText = id;
              PageStorage.of(context)?.writeState(
                  context, id,
                  identifier: ValueKey('test'));
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
        )
    );
  }

  Widget connect() {
    return SizedBox(width: 300, height: 35, child: RaisedButton(
      onPressed: () {
        _getTransactionId(ScgatewayIntent.CONNECT, null);
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
                            controller: _textEditingController,
                          ),
                          new FlatButton(
                            child: new Text("Save"),
                              onPressed: () {
                                setState((){
                                  this._transactionId = _textEditingController.text;
                                });
                                Navigator.pop(context);
                              },
                          )
                        ],
                    )
                  )
            ), context: context);
      },
      child: const Text('Enter Transaction Id', style: TextStyle(fontSize: 20)),
    ));
  }

  Widget copyTransactionId() {
    return SizedBox(width: 300, height: 35, child: RaisedButton(
      onPressed: () {
        ClipboardManager.copyToClipBoard(_transactionId).then((result) {
          final snackBar = SnackBar(
            content: Text('Copied to Clipboard: ' + _transactionId),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {},
            ),
          );
          Scaffold.of(context).showSnackBar(snackBar);
        });
      },
      child: const Text('Copy Transaction Id', style: TextStyle(fontSize: 20)),
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
            ),
            FittedBox(
              alignment: Alignment.center,
              fit: BoxFit.none,
              child: copyTransactionId(),
            )
          ],
        ),
      ),
    );
  }
}
