import 'dart:convert';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scgateway_flutter_plugin_example/models/ExitedSmallcaseDTO.dart';
import 'package:scgateway_flutter_plugin_example/models/InvestmentsDataDTO.dart';
import 'package:scgateway_flutter_plugin_example/models/SmallcasesDTO.dart';
import 'package:scgateway_flutter_plugin_example/screens/ExitedSmallcasesList.dart';
import 'package:scgateway_flutter_plugin_example/screens/InvestmentsList.dart';
import 'package:scgateway_flutter_plugin_example/screens/SmallcasesList.dart';

import '../Styles.dart';
import '../gateway.dart';

class SmtScreen extends StatefulWidget {
  SmtScreen({Key key}) : super(key: key);

  @override
  _SmtScreenState createState() => _SmtScreenState();
}

class _SmtScreenState extends State<SmtScreen> {
  TextEditingController _textEditingController;

  String _smallplugEndpoint = "";

  String _headerColor = "";
  double _headerOpacity = 1.0;
  String _backIconColor = "";
  double _backIconOpacity = 1.0;

  @override
  void initState() {
    super.initState();

    _smallplugEndpoint = PageStorage.of(context)
        ?.readState(context, identifier: ValueKey('smallplugEndpoint'));

    _textEditingController =
        new TextEditingController(text: _smallplugEndpoint);

    Gateway.getAllSmallcases().then((value) => _populateSmallCases(value));
  }

  List<SmallcasesDTO> items = [];

  void _showSmallcases(BuildContext context) async {
    // Gateway.getAllSmallcases().then((value) => _populateSmallCases(value));

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SmallcasesList(items: items),
        ));
  }

  Future<void> _populateSmallCases(String jsonString) async {
    final Map<String, dynamic> responseData = jsonDecode(jsonString);

    print("ResponseData = $responseData");

    var list = responseData['data']['smallcases'] as List;
    // var list = responseData['smallcases'] as List;
    // print("List runtime type = $list.runtimeType");

    List<SmallcasesDTO> smallcases =
        list.map((i) => SmallcasesDTO.fromJson(i)).toList();

    setState(() {
      items = smallcases;
    });

    print("items: $items");
  }

  void _getUserInvestments(BuildContext context) async {
    Gateway.getAllUserInvestments()
        .then((value) => _showUserInvestments(context, value));
  }

  void _showUserInvestments(BuildContext context, String data) {
    final Map<String, dynamic> responseData = jsonDecode(data);

    var investments = responseData['data'] as List;
    // print("List runtime type = $investments.runtimeType");

    List<InvestmentsDataDTO> investmentsList =
        investments?.map((i) => InvestmentsDataDTO.fromJson(i))?.toList();

    print("decoded investments: $investmentsList");

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InvestmentsList(investments: investmentsList),
        ));
  }

  void _getExitedSmallcases(BuildContext context) async {
    Gateway.getAllExitedSmallcases()
        .then((value) => _showExitedSmallcases(context, value));
  }

  void _launchSmallplug() async {
    Gateway.openSmallplugWithBranding('', '', this._headerColor,
            this._headerOpacity, this._backIconColor, this._backIconOpacity)
        .then((value) => _showAlertDialog(value));
  }

  void _launchSmallplugWithEndpoint(String endpointVal) async {
    Gateway.openSmallplug(endpointVal).then((value) => _showAlertDialog(value));
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

  void _showExitedSmallcases(BuildContext context, String data) {
    final Map<String, dynamic> responseData = jsonDecode(data);

    print("Exited Smallcases: $responseData");

    var exits = responseData['data'] as List;

    List<ExitedSmallcaseDTO> exitedInvestments =
        exits.map((e) => ExitedSmallcaseDTO.fromJson(e)).toList();

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ExitedSmallcasesList(exitedSmallcases: exitedInvestments),
        ));
  }

  //----------------------------------  WIDGETS -------------------------------------- //

  Widget smallcases(BuildContext context) {
    return SizedBox(
        width: 300,
        height: 35,
        child: ElevatedButton(
          onPressed: () => _showSmallcases(context),
          child: const Text('SMALLCASES', style: TextStyle(fontSize: 20)),
        ));
  }

  Widget userInvestments() {
    return SizedBox(
        width: 300,
        height: 35,
        child: ElevatedButton(
          onPressed: () => _getUserInvestments(context),
          child: const Text('USER INVESTMENTS', style: TextStyle(fontSize: 20)),
        ));
  }

  Widget exitedSmallcases() {
    return SizedBox(
        width: 300,
        height: 35,
        child: ElevatedButton(
          onPressed: () => _getExitedSmallcases(context),
          child:
              const Text('EXITED SMALLCASES', style: TextStyle(fontSize: 20)),
        ));
  }

  Widget smallplug() {
    return SizedBox(
        width: 300,
        height: 35,
        child: ElevatedButton(
          onPressed: () => _launchSmallplug(),
          child: const Text('SMALLPLUG', style: TextStyle(fontSize: 20)),
        ));
  }

  Widget smallplugWithTargetEndpoint() {
    // return SizedBox(width: 300, height: 35, child: ElevatedButton(
    //   onPressed: () => _launchSmallplugWithEndpoint(),
    //   child: const Text('SMALLPLUG + Endpoint', style: TextStyle(fontSize: 20)),
    // ));

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
                                    hintText: "Enter Target Endpoint"),
                                controller: _textEditingController,
                              ),
                              new ElevatedButton(
                                child: new Text("Go"),
                                onPressed: () {
                                  setState(() {
                                    this._smallplugEndpoint =
                                        _textEditingController.text;
                                  });
                                  _launchSmallplugWithEndpoint(
                                      this._smallplugEndpoint);
                                  Navigator.pop(context);
                                },
                              )
                            ],
                          )));
                });
          },
          child: const Text('Smallplug + Endpoint',
              style: TextStyle(fontSize: 20)),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('SMT'),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.only(top: 10, left: 15, right: 10),
          children: <Widget>[
            FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.none,
              child: smallcases(context),
            ),
            FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.none,
              child: userInvestments(),
            ),
            FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.none,
              child: exitedSmallcases(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: TextFormField(
                onChanged: (value) => {
                  this.setState(() {
                    _headerColor = value;
                  })
                },
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Header Color',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: TextFormField(
                onChanged: (value) => {
                  this.setState(() {
                    _headerOpacity = double.tryParse(value);
                  })
                },
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Header Color Opacity',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: TextFormField(
                onChanged: (value) => {
                  this.setState(() {
                    _backIconColor = value;
                  })
                },
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'back icon Color',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: TextFormField(
                onChanged: (value) => {
                  this.setState(() {
                    _backIconOpacity = double.tryParse(value);
                  })
                },
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'back icon Color opacity',
                ),
              ),
            ),
            FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.none,
              child: smallplug(),
            ),
            FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.none,
              child: smallplugWithTargetEndpoint(),
            ),
          ],
        ),
      ),
    );
  }
}
