import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:scgateway_flutter_plugin/scgateway_flutter_plugin.dart';
import 'package:scgateway_flutter_plugin_example/app/global/SmartInvestingAppRepository.dart';


class InvestmentDetails extends StatelessWidget {
  dynamic investmentsDataDTO;

  InvestmentDetails({Key? key, @required this.investmentsDataDTO})
      : super(key: key);

  void _triggerInvestmentAction(String type, BuildContext context) {
    var orderConfig = {
      "type": type,
      "iscid": investmentsDataDTO["investmentItem"]["iscid"]
    };
repository.triggerTransaction(ScgatewayIntent.TRANSACTION, orderConfig, false, context);
   
  }

  Future<void> _sipSetup(BuildContext context) async {
    var orderConfig = {"iscid": this.investmentsDataDTO["investmentItem"]["iscid"]};

repository.triggerTransaction(ScgatewayIntent.SIP_SETUP, orderConfig, false, context);

  }

  Future<void> _cancelAmo(BuildContext context) async {
    var orderConfig = {"iscid": this.investmentsDataDTO["investmentItem"]["iscid"]};

repository.triggerTransaction(ScgatewayIntent.CANCEL_AMO, orderConfig, false, context);
  }

  void _markSmallcaseArchive(BuildContext context) async {

final response = await ScgatewayFlutterPlugin.markSmallcaseArchive(investmentsDataDTO["investmentItem"]["iscid"]);
       repository.showAlertDialog(response ?? "", context);
  }

  Future<void> _showAlertDialog(String message, BuildContext context) async {
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

  Widget investmentInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Container(
          constraints: BoxConstraints.tightFor(width: 60.0),
          child: Image.network(
              "https://assets.smallcase.com/images/smallcases/200/${investmentsDataDTO["investmentItem"]["scid"]}.png",
              fit: BoxFit.fitWidth),
        ),
        const SizedBox(width: 10),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(this.investmentsDataDTO["investmentItem"]["name"]),
            Text(
              this.investmentsDataDTO["investmentItem"]["shortDescription"],
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            )
          ],
        )),
      ],
    );
  }

  Widget investmentActions(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        ElevatedButton(
          style: ElevatedButton.styleFrom(onPrimary: Colors.green),
          onPressed: () => _triggerInvestmentAction("repair", context),
          child: const Text('Repair', style: TextStyle(fontSize: 20)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(onPrimary: Colors.green),
          onPressed: () =>
              _triggerInvestmentAction("investmore".toUpperCase(), context),
          child: const Text('INVEST MORE', style: TextStyle(fontSize: 20)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(onPrimary: Colors.green),
          onPressed: () => _triggerInvestmentAction("manage", context),
          child: const Text('Manage', style: TextStyle(fontSize: 20)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(onPrimary: Colors.green),
          onPressed: () => _sipSetup(context),
          child: const Text('SIP SETUP', style: TextStyle(fontSize: 20)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(onPrimary: Colors.green),
          onPressed: () => _triggerInvestmentAction("rebalance", context),
          child: const Text('Rebalance', style: TextStyle(fontSize: 20)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(onPrimary: Colors.green),
          onPressed: () => _triggerInvestmentAction("sip", context),
          child: const Text('SIP Order', style: TextStyle(fontSize: 20)),
        ),
        ElevatedButton(
          onPressed: () => _cancelAmo(context),
          style: ElevatedButton.styleFrom(onPrimary: Colors.green),
          child: const Text('Cancel AMO', style: TextStyle(fontSize: 20)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(onPrimary: Colors.green),
          onPressed: () => _triggerInvestmentAction("exit", context),
          child: const Text('Exit', style: TextStyle(fontSize: 20)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(onPrimary: Colors.green),
          onPressed: () => _markSmallcaseArchive(context),
          child: const Text('Archive', style: TextStyle(fontSize: 20)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(onPrimary: Colors.green),
          onPressed: () => _triggerInvestmentAction("DUMMY", context),
          child: const Text('Place Dummy Order', style: TextStyle(fontSize: 20)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(investmentsDataDTO["investmentItem"]["name"])),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.only(top: 10, left: 15, right: 10),
          children: <Widget>[
            investmentInfo(),
            SizedBox(height: 30),
            Align(
              alignment: Alignment.bottomCenter,
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[investmentActions(context)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
