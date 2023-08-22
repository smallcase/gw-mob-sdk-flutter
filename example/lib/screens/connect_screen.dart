import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'dart:async';
import 'dart:convert';
import 'package:clipboard/clipboard.dart';

import 'package:scgateway_flutter_plugin/scgateway_flutter_plugin.dart';
import 'package:scgateway_flutter_plugin_example/gateway.dart';
import 'package:scgateway_flutter_plugin_example/lamf/screens/LoansScreen.dart';

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

  String _gateway = "gatewaydemo";
  String authToken = null;

  String _userIdText = "";

  // String _authToken = "";

  String _transactionId = "";
  String _sdkVersion = "";
  Environment environment;

  Map<int, Widget> _environments = {
    0: Text('Prod'),
    1: Text('Dev'),
    2: Text('Staging')
  };

  @override
  initState() {
    super.initState();

    ScgatewayFlutterPlugin.getSdkVersion().then((value) => setState(() {
          this._sdkVersion = value;
        }));

    _userIdText = PageStorage.of(context)
        ?.readState(context, identifier: ValueKey('test'));
    _textEditingController = new TextEditingController(text: _userIdText);
    _environmentSelected = PageStorage.of(context)
        ?.readState(context, identifier: ValueKey('selectedEnv'));
    _transactionId = PageStorage.of(context)
        ?.readState(context, identifier: ValueKey('txnId'));
  }

  Future<void> _initSession() async {
    switch (_environmentSelected) {
      case 1:
        environment = Environment.dev();
        break;

      case 2:
        environment = Environment.staging();
        break;

      default:
        environment = Environment.prod();
        break;
    }

    // List<String> brokers = ['kite','hdfc','iifl'];

    List<String> brokers = [];
    ScgatewayFlutterPlugin.setConfigEnvironment(environment.gatewayEnvironment,
            environment.gatewayName, _leprechaunMode, brokers,
            isAmoenabled: _isAmoEnabled)
        .then((setupResponse) => Gateway.getSessionToken(
                environment, _userIdText ?? "", _leprechaunMode, _isAmoEnabled, token: authToken)
            .then((value) => _showAlertDialog(value)));
  }

  Future<void> _getTransactionId(String intent, Object orderConfig) async {
    Gateway.getTransactionIdAndStartTxn(intent, orderConfig)
        .then((value) => _onUserConnected(value));
  }

  Future<void> _triggerTransactionFromTxnId(String txnId) async {
    Gateway.triggerTransactionWithTransactionId(txnId)
        .then((value) => _showAlertDialog(value));
  }

  Future<void> _onUserConnected(String connectResponse) async {
    print("Connect Transaction response: $connectResponse");

    final Map<String, dynamic> responseData = jsonDecode(connectResponse);

    // print("ResponseData = $responseData");
    var connectTxnSuccess = responseData['success'] as bool;
    print("Connect Transaction success: $connectTxnSuccess");

    if (connectTxnSuccess == true) {
      final Map<String, dynamic> connectJsonData =
          jsonDecode(responseData['data'] as String);

      var authToken = connectJsonData['smallcaseAuthToken'] as String;

      print("auth token = $authToken");

      Map data = {'id': _userIdText, 'smallcaseAuthToken': authToken};

      String bodyData = json.encode(data);

      print("On User connected body: $data");

      var url = Uri.parse(Gateway.baseURL + 'user/connect');

      final http.Response response = await http.post(url,
          headers: <String, String>{
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'POST, GET, OPTIONS, PUT',
            'Accept': 'application/json',
            'content-type': 'application/json'
          },
          body: bodyData);

      print("On user Connect: ");
      print(response.body);
    }

    if (Gateway.transactionId.isNotEmpty) {
      setState(() {
        this._transactionId = Gateway.transactionId;
        PageStorage.of(context)?.writeState(context, this._transactionId,
            identifier: ValueKey('txnId'));
      });
    }

    _showAlertDialog(connectResponse);

    // Map data = {
    //   'id': _userIdText,
    //   'smallcaseAuthToken': authToken
    // };
    //
    // String bodyData = json.encode(data);
    //
    // print("On User connected body: $data");
    //
    // var url = Uri.parse(Gateway.baseURL + 'user/connect');
    //
    // final http.Response response = await http.post(
    //     url,
    //
    //     headers: <String, String>{
    //       'Access-Control-Allow-Origin': '*',
    //       'Access-Control-Allow-Methods': 'POST, GET, OPTIONS, PUT',
    //       'Accept': 'application/json',
    //       'content-type':'application/json'
    //     },
    //
    //     body: bodyData
    // );
    //
    // print("On user Connect: ");
    // print(response.body);
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
              PageStorage.of(context)?.writeState(context, value,
                  identifier: ValueKey('selectedEnv'));
            });
          }),
    );
  }

  Widget environmentWidget() {
    return Row(
      children: <Widget>[Text('Environment'), segmentedControl()],
    );
  }

  Widget gateway() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        SizedBox(height: 50),
        Text('Gateway '),
        SizedBox(
          width: 200,
          height: 30,
          child: TextField(
            decoration: InputDecoration(
              filled: true,
              labelText: 'gatewaydemo',
            ),
          ),
        )
      ],
    );
  }

  String getUserIdText() {
    if (_userIdText != null) {
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
        SizedBox(
          width: 200,
          height: 30,
          child: TextField(
            decoration: InputDecoration(
              filled: true,
              labelText: getUserIdText(),
            ),
            onChanged: (id) {
              setState(() {
                _userIdText = id;
                PageStorage.of(context)
                    ?.writeState(context, id, identifier: ValueKey('test'));
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
        SizedBox(
            width: 60,
            height: 20,
            child: Switch(
                activeTrackColor: Colors.green,
                activeColor: Colors.green,
                value: _leprechaunMode,
                onChanged: (value) {
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
        SizedBox(
            width: 60,
            height: 20,
            child: Switch(
                activeTrackColor: Colors.green,
                activeColor: Colors.green,
                value: _isAmoEnabled,
                onChanged: (value) {
                  setState(() {
                    _isAmoEnabled = value;
                  });
                }))
      ],
    );
  }

  Widget setup() {
    return SizedBox(
        width: 300,
        height: 35,
        child: ElevatedButton(
          onPressed: _initSession,
          child: const Text('Setup', style: TextStyle(fontSize: 20)),
        ));
  }

  Widget connect() {
    return SizedBox(
        width: 300,
        height: 35,
        child: ElevatedButton(
          onPressed: () {
            _getTransactionId(ScgatewayIntent.CONNECT, null);
          },
          child: const Text('Connect', style: TextStyle(fontSize: 20)),
        ));
  }

  Widget enterTransactionId() {
    return SizedBox(
        width: 300,
        height: 35,
        child: ElevatedButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return new Dialog(
                      child: SizedBox(
                          width: 300,
                          height: 96,
                          child: new Column(
                            children: <Widget>[
                              new TextField(
                                decoration: new InputDecoration(
                                    hintText: "Enter Transaction Id"),
                                controller: _textEditingController,
                              ),
                              new ElevatedButton(
                                child: new Text("Save"),
                                onPressed: () {
                                  setState(() {
                                    this._transactionId =
                                        _textEditingController.text;
                                  });
                                  _triggerTransactionFromTxnId(
                                      this._transactionId);
                                  Navigator.pop(context);
                                },
                              )
                            ],
                          )));
                });
          },
          child: const Text('Enter Transaction Id',
              style: TextStyle(fontSize: 20)),
        ));
  }

  Widget copyTransactionId() {
    return SizedBox(
        width: 300,
        height: 35,
        child: ElevatedButton(
          onPressed: () {
            FlutterClipboard.copy(_transactionId).then((result) {
              final snackBar = SnackBar(
                content: Text('Copied to Clipboard: ' + _transactionId),
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () {},
                ),
              );
              // Scaffold.of(context).showSnackBar(snackBar);
            });
          },
          child:
              const Text('Copy Transaction Id', style: TextStyle(fontSize: 20)),
        ));
  }

  Widget _navigateToLoansScreen() {
    return SizedBox(
        width: 300,
        height: 35,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(
                    builder: (context) => LoansScreen()
                ));
          },
          child:
          const Text('Go to Loans Screen', style: TextStyle(fontSize: 20)),
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
            Text(
              _sdkVersion,
              textAlign: TextAlign.center,
            ),
            FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.none,
              child: environmentWidget(),
            ),
            FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.none,
              child: gateway(),
            ),
            TextField(
                onChanged: (value) => authToken = value,
                decoration: InputDecoration(
                  filled: true,
                  labelText: 'Enter custom JWT',
                )),
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
            ),
            FittedBox(
              alignment: Alignment.center,
              fit: BoxFit.none,
              child: _navigateToLoansScreen(),
            )
          ],
        ),
      ),
    );
  }
}
