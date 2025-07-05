import 'dart:convert';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';
import 'package:scgateway_flutter_plugin/scgateway_flutter_plugin.dart';

import '../../smartinvesting.dart';
import 'SIConfigs.dart';

SmartInvestingAppRepository get repository {
  return SmartInvestingAppRepository.singleton();
}

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

  static SmartInvesting get smartInvesting {
    return SmartInvesting.fromEnvironment(_singleton!.scGatewayConfig.value);
  }

  final environment = BehaviorSubject.seeded(SIEnvironment.PRODUCTION);

  final siConfig = BehaviorSubject.seeded(SIConfig(loansUserId: "020896"));
  final scGatewayConfig = BehaviorSubject.seeded(ScGatewayConfig.prod());
  final scLoanConfig = BehaviorSubject.seeded(ScLoanConfig.prod());

  final smartInvestingUserId = BehaviorSubject<String?>.seeded(null);
  final customAuthToken = BehaviorSubject<String?>.seeded(null);
  var appState = BehaviorSubject<String>.seeded("/");

  //SMT Screen
    final headerColor = BehaviorSubject<String?>.seeded(null);
    final headerOpacity = BehaviorSubject<double?>.seeded(null);
    final backIconColor = BehaviorSubject<String?>.seeded(null);
    final backIconOpacity = BehaviorSubject<double?>.seeded(null);
    final smallplugEndpoint = BehaviorSubject<String?>.seeded(null);

Color getColorFromHex(String hexColor) {
  hexColor = hexColor.replaceAll('#', '');
  int parsedColor = int.parse(hexColor, radix: 16);
  return Color(parsedColor).withOpacity(1.0); 
}

  final notes = BehaviorSubject<String?>.seeded(null);
  final date = BehaviorSubject<String?>.seeded(null);

//MF Transaction
  var transactionID = BehaviorSubject<String>.seeded("");


//Leadgen
  var withLoginCTA = BehaviorSubject<bool>.seeded(false);
  final leadgenUserName = BehaviorSubject<String?>.seeded(null);
  final leadgenUserEmail = BehaviorSubject<String?>.seeded(null);
  final leadgenUserContact = BehaviorSubject<String?>.seeded(null);

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

Future<String> triggerTransaction(
    String? intent,
    Object? orderConfig,
    bool withTransactionID, 
    BuildContext context, 
    {Object? assetConfig,
    bool isMF = false,
    bool isPostBackStatus = false}) async {

  var transactionId = transactionID.value;

  if (withTransactionID == false) {
    print("AD:: SMART INVESTING USER ID INSIDE TRIGGER TRANSACTION VALUE -- ${smartInvestingUserId.value}");
    try {
      transactionId = await SmartInvesting.fromEnvironment(scGatewayConfig.value).getTransactionId(
        smartInvestingUserId.value ?? "", intent, orderConfig,
        assetConfig: assetConfig);
    } catch (e) {
      print("Error fetching transaction ID: $e");
      repository.showAlertDialog("Error fetching transaction ID: $e", context);
      return "Error fetching transaction ID";
    }
  }

  var response = "";

  try {
    if (isMF) {
      response = await ScgatewayFlutterPlugin.triggerMfGatewayTransaction(transactionId) ?? "";
      repository.showAlertDialog(response.toString(), context);
      
      if (isPostBackStatus) {
        try {
          final postBackStatusResponse = await smartInvesting.getPostBackStatus(transactionId);
          repository.showAlertDialog(postBackStatusResponse.toString(), context);
        } catch (e) {
          print("Gateway Exception!! getPostBackStatus $transactionId : $e");
          repository.showAlertDialog("Error fetching post-back status: $e", context);
          return "Error fetching post-back status";
        }
      }
    } else {
      response = await ScgatewayFlutterPlugin.triggerGatewayTransaction(transactionId) ?? "";
      repository.showAlertDialog(response.toString(), context);
    }
     try {
    // Parse the JSON response
    var jsonResponse = json.decode(response);
    var data = json.decode(jsonResponse['data']);
    
    // Check conditions
    if (repository.smartInvestingUserId.value != null && jsonResponse['transaction'] == "CONNECT") {
      await smartInvesting.connectBroker(repository.smartInvestingUserId.value!, data['smallcaseAuthToken']);
    }
  } catch (e) {
    print("Error parsing JSON response: $e");
    // You might want to handle this error differently
  }
  
  } catch (e) {
    print("Error triggering transaction: $e");
    repository.showAlertDialog("Error triggering transaction: $e", context);
    return "Error triggering transaction";
  }

 

  return response;
}

  dispose() {
    environment.close();
    scGatewayConfig.close();
    scLoanConfig.close();
    transactionID.close();
    _singleton = null;
  }
}
