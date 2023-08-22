import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scgateway_flutter_plugin/SCLoans.dart';

import '../../gateway.dart';

class LoansScreen extends StatefulWidget {
  const LoansScreen({Key key}) : super(key: key);

  @override
  State<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends State<LoansScreen> {

  int _environmentSelected = 0;
  Map<int, Widget> _environments = {
    0: Text('Prod'),
    1: Text('Dev'),
    2: Text('Staging')
  };

  //region Environment Widget

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

  //endregion

  //region Gateway input
  String gatewayName = "gatewaydemo";

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
  //endregion

  //region Setup
  SCLoanEnvironment environment;

  Widget setup() {
    return SizedBox(
        width: 300,
        height: 35,
        child: ElevatedButton(
          onPressed: _setupScLoans,
          child: const Text('Setup', style: TextStyle(fontSize: 20)),
        ));
  }

  Future<void> _setupScLoans() async {
    switch (_environmentSelected) {
      case 1:
        environment = SCLoanEnvironment.DEVELOPMENT;
        gatewayName = "gatewaydemo-dev";
        break;

      case 2:
        environment = SCLoanEnvironment.STAGING;
        gatewayName = "gatewaydemo-stag";
        break;

      default:
        environment = SCLoanEnvironment.PRODUCTION;
        gatewayName = "gatewaydemo";
        break;
    }

    SCLoans.setup(environment, gatewayName).then((setupResponse) => _showAlertDialog("success"));
  }

  //endregion

  //region SCLoans interaction
  String interactionToken;

  Widget interactionTokenInput() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        SizedBox(height: 50),
        Text('Interaction Token '),
        SizedBox(
          width: 200,
          height: 30,
          child: TextField(
            onSubmitted: (value) {
              this.interactionToken = value;
            },
            decoration: InputDecoration(
              filled: true,
              labelText: '',
            ),
          ),
        )
      ],
    );
  }

  Widget _applyForLoan() {
    return SizedBox(
        width: 300,
        height: 35,
        child: ElevatedButton(
          onPressed: _apply,
          child: const Text('Apply', style: TextStyle(fontSize: 20)),
        ));
  }

  Future<void> _apply() async {
    SCLoans.apply(this.interactionToken).then((response) => _showAlertDialog(response));
  }

  Widget _payInterestOrPrincipal() {
    return SizedBox(
        width: 300,
        height: 35,
        child: ElevatedButton(
          onPressed: _pay,
          child: const Text('Pay', style: TextStyle(fontSize: 20)),
        ));
  }

  Future<void> _pay() async {
    SCLoans.pay(this.interactionToken).then((response) => _showAlertDialog(response));
  }

  Widget _withdrawAmount() {
    return SizedBox(
        width: 300,
        height: 35,
        child: ElevatedButton(
          onPressed: _withdraw,
          child: const Text('Withdraw', style: TextStyle(fontSize: 20)),
        ));
  }

  Future<void> _withdraw() async {
    SCLoans.apply(this.interactionToken).then((response) => _showAlertDialog(response));
  }

  //endregion

  //region Utility

  Future<void> _showAlertDialog(String message) async {
    // FlutterClipboard.copy(message);

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('SDK response'),
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

  //endregion

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SCLoans'),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.only(top: 10, left: 15, right: 10),
          children: <Widget>[
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
            FittedBox(
              alignment: Alignment.center,
              fit: BoxFit.none,
              child: setup(),
            ),
            FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.none,
              child: interactionTokenInput(),
            ),
            FittedBox(
              alignment: Alignment.center,
              fit: BoxFit.none,
              child: _applyForLoan(),
            ),
            FittedBox(
              alignment: Alignment.center,
              fit: BoxFit.none,
              child: _payInterestOrPrincipal(),
            ),
            FittedBox(
              alignment: Alignment.center,
              fit: BoxFit.none,
              child: _withdrawAmount(),
            ),
          ],
        ),
      ),
    );
  }

}
