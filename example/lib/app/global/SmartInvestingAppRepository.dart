import 'dart:ffi';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';
import 'package:scgateway_flutter_plugin/scgateway_flutter_plugin.dart';
import 'package:scgateway_flutter_plugin_example/app/global/SIConfigs.dart';
import 'package:scgateway_flutter_plugin_example/smartinvesting.dart';

class SmartInvestingAppRepository {
  SmartInvestingAppRepository._() {
    environment.forEach((element) {
      if (environment.isClosed) return;
      scGatewayConfig.value = element.scGatewayConfig;
      scLoanConfig.value = element.scLoanConfig;
    });
  }

  static SmartInvestingAppRepository? _singleton;
  factory SmartInvestingAppRepository.singleton() =>
      _singleton ??= SmartInvestingAppRepository._();

  final environment = BehaviorSubject.seeded(SIEnvironment.PRODUCTION);

  final siConfig = BehaviorSubject.seeded(SIConfig(loansUserId: "020896"));
  final scGatewayConfig = BehaviorSubject.seeded(ScGatewayConfig.prod());
  final scLoanConfig = BehaviorSubject.seeded(ScLoanConfig.prod());

  final smartInvestingUserId = BehaviorSubject<String?>.seeded(null);
  final customAuthToken = BehaviorSubject<String?>.seeded(null);
  var appState = BehaviorSubject<String>.seeded("/");

//MF Transaction
  var isMFTransactionEnabled = BehaviorSubject<bool>.seeded(false);
  var transactionID = BehaviorSubject<String>.seeded("");


  //showAlert Function -
  //alert 
  Future<void> showAlertDialog(String message, BuildContext context) async {
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


//Trigger transaction - 

 Future<String> TriggerTransaction(
      String? intent,
      Object? orderConfig,
      bool withTransactionID, 
      BuildContext context, 
      {Object? assetConfig,
      bool isMF = false}) async {
      var transactionId = transactionID.value;
      if (withTransactionID == false) {
      transactionId = await SmartInvesting.fromEnvironment(scGatewayConfig.value).getTransactionId(
        smartInvestingUserId.value ?? "", intent, orderConfig,
        assetConfig: assetConfig);
      }
      var response = "";
      if (isMF) {
       response =  await ScgatewayFlutterPlugin.triggerMfGatewayTransaction(
          transactionId) ?? "";
          showAlertDialog(response.toString(), context);
      return response;
    }
    response = await ScgatewayFlutterPlugin.triggerGatewayTransaction(
        transactionId) ?? "";
        showAlertDialog(response.toString(), context);
    return response;
  }

  dispose() {
    environment.close();
    scGatewayConfig.close();
    scLoanConfig.close();
    isMFTransactionEnabled.close();
    transactionID.close();
    _singleton = null;
  }
}
