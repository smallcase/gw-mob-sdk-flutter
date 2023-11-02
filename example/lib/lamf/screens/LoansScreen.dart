import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scgateway_flutter_plugin/ScLoan.dart';

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
      child: CupertinoSlidingSegmentedControl<int>(
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
    return TextField(
      decoration: InputDecoration(
        filled: true,
        labelText: 'Gateway Name',
      ),
    );
  }
  //endregion

  //region Setup
  SCLoanEnvironment environment;

  Widget setup() {
    return ElevatedButton(
      onPressed: _setupScLoans,
      child: const Text('Setup', style: TextStyle(fontSize: 20)),
    );
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

    SCLoans.setup(environment, gatewayName)
        .then((setupResponse) => _showAlertDialog("success"));
  }

  //endregion

  //region SCLoans interaction
  String interactionToken;

  Widget interactionTokenInput() {
    return TextField(
      onChanged: (value) => {this.interactionToken = value},
      decoration: InputDecoration(
        filled: true,
        labelText: 'Interaction Token',
      ),
    );
  }

  Widget _applyForLoan() {
    return ElevatedButton(
      onPressed: _apply,
      child: const Text('Apply', style: TextStyle(fontSize: 20)),
    );
  }

  Future<void> _apply() async {
    SCLoans.apply(this.interactionToken)
        .then((response) => _showAlertDialog(response));
  }

  Widget _payInterestOrPrincipal() {
    return ElevatedButton(
      onPressed: _pay,
      child: const Text('Pay', style: TextStyle(fontSize: 20)),
    );
  }

  Future<void> _pay() async {
    SCLoans.pay(this.interactionToken)
        .then((response) => _showAlertDialog(response));
  }

  Widget _withdrawAmount() {
    return ElevatedButton(
      onPressed: _withdraw,
      child: const Text('Withdraw', style: TextStyle(fontSize: 20)),
    );
  }

  Future<void> _withdraw() async {
    SCLoans.apply(this.interactionToken)
        .then((response) => _showAlertDialog(response));
  }

  Future<void> _service() async {
    SCLoans.service(this.interactionToken)
        .then((response) => _showAlertDialog(response));
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
          children: [
            Row(
              children: [
                Text("Environment"),
              ],
            ),
            environmentWidget(),
            TextField(
                decoration: InputDecoration(
              filled: true,
              labelText: 'Gateway Name',
            )),
            setup(),
            interactionTokenInput(),
            _applyForLoan(),
            _payInterestOrPrincipal(),
            _withdrawAmount(),
            ElevatedButton(
              onPressed: _service,
              child: const Text('Service', style: TextStyle(fontSize: 20)),
            )
          ],
        ),
      ),
    );
  }
}
