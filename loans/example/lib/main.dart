import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scloans/ScLoan.dart';

void main() {
  runApp(LoansScreen());
}

class LoansScreen extends StatefulWidget {
  //const LoansScreen({Key key}) : super(key: key);

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

  Map<dynamic, dynamic> getEnvMeta() {
    final meta = {};
    switch (_environmentSelected) {
      case 1:
        meta["env"] = ScLoanEnvironment.DEVELOPMENT;
        meta["gateway"] = "gatewaydemo-dev";
        break;

      case 2:
        meta["env"] = ScLoanEnvironment.STAGING;
        meta["gateway"] = "gatewaydemo-stag";
        break;

      default:
        meta["env"] = ScLoanEnvironment.PRODUCTION;
        meta["gateway"] = "gatewaydemo";
        break;
    }
    return meta;
  }
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
              _environmentSelected = value ?? 0;
              gatewayName = getEnvMeta()["gateway"];
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
        onChanged: (value) => gatewayName = value);
  }
  //endregion

  //region Setup
  late ScLoanEnvironment environment;

  Widget setup() {
    return ElevatedButton(
      onPressed: _setupScLoans,
      child: const Text('Setup', style: TextStyle(fontSize: 20)),
    );
  }

  Future<void> _setupScLoans() async {
    final envMeta = getEnvMeta();
    environment = envMeta["env"];
    print("_setupScLoans $gatewayName");
    try {
      final response = await ScLoan.setup(ScLoanConfig(environment, gatewayName));
      _showAlertDialog(response);
    } on ScLoanError catch (e) {
     _showAlertDialog(e);
    }
  }

  //endregion

  //region SCLoans interaction
  String interactionToken = "";

  Widget interactionTokenInput() {
    return TextField(
      enableInteractiveSelection: true,
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
    try {
      final response = await ScLoan.apply(ScLoanInfo(interactionToken));
      _showAlertDialog(response);
    } on ScLoanError catch (e) {
     _showAlertDialog(e);
    }
  }

  Widget _payInterestOrPrincipal() {
    return ElevatedButton(
      onPressed: _pay,
      child: const Text('Pay', style: TextStyle(fontSize: 20)),
    );
  }

  Future<void> _pay() async {
    try {
      final response = await ScLoan.pay(ScLoanInfo(interactionToken));
      _showAlertDialog(response);
    } on ScLoanError catch (e) {
     _showAlertDialog(e);
    }
  }

  Widget _withdrawAmount() {
    return ElevatedButton(
      onPressed: _withdraw,
      child: const Text('Withdraw', style: TextStyle(fontSize: 20)),
    );
  }

  Future<void> _withdraw() async {
    try {
      final response = await ScLoan.withdraw(ScLoanInfo(interactionToken));
      _showAlertDialog(response);
    } on ScLoanError catch (e) {
     _showAlertDialog(e);
    }
  }

  Future<void> _service() async {
    try {
      final response = await ScLoan.service(ScLoanInfo(interactionToken));
      _showAlertDialog(response);
    } on ScLoanError catch (e) {
     _showAlertDialog(e);
    }
  }

  //endregion

  //region Utility

  Future<void> _showAlertDialog(ScLoanResponse message) async {
    // FlutterClipboard.copy(message);

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('SDK response'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[Text("$message")],
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
                  FlutterClipboard.copy(message.toString());
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
                onChanged: (value) => gatewayName = value,
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
