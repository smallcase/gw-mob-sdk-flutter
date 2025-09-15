import 'dart:async';
import 'dart:convert';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';
import 'package:scgateway_flutter_plugin/scgateway_flutter_plugin.dart';
import 'package:scgateway_flutter_plugin/scgateway_events.dart';
import 'package:scloans/sc_loan.dart';
import 'package:scloans/sc_loan_events.dart';

import '../../smartinvesting.dart';
import 'SIConfigs.dart' as si;

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

    // Subscribe to native event streams and pipe to BehaviorSubjects
    _gatewaySub = ScgatewayEvents.eventStream.listen((jsonString) {
      // Parse and append gateway events
      final event = ScgatewayEvents.parseEvent(jsonString);
      if (event != null) {
        _appendGatewayEvent(event);
      } else {
        _appendGatewayEvent({"type": "raw", "data": jsonString, "timestamp": DateTime.now().millisecondsSinceEpoch});
      }
    }, onError: (e) {
      _appendGatewayEvent({"type": "error", "data": e.toString(), "timestamp": DateTime.now().millisecondsSinceEpoch});
    });

    // _loansSub = ScLoanEvents.eventStream.listen((event) {
    //   _appendLoansEvent(event);
    // }, onError: (e) {
    //   _appendLoansEvent({"type": "error", "data": e.toString(), "timestamp": DateTime.now().millisecondsSinceEpoch});
    // });
  }

  static SmartInvestingAppRepository? _singleton;
  factory SmartInvestingAppRepository.singleton() =>
      _singleton ??= SmartInvestingAppRepository._();

  static SmartInvesting get smartInvesting {
    return SmartInvesting.fromEnvironment(_singleton!.scGatewayConfig.value);
  }

  final environment = BehaviorSubject.seeded(si.SIEnvironment.PRODUCTION);

  final siConfig = BehaviorSubject.seeded(si.SIConfig(loansUserId: "020896"));
  final scGatewayConfig = BehaviorSubject.seeded(si.ScGatewayConfig.prod());
  final scLoanConfig = BehaviorSubject.seeded(si.ScLoanConfig.prod());

  final smartInvestingUserId = BehaviorSubject<String?>.seeded(null);
  final customAuthToken = BehaviorSubject<String?>.seeded(null);
  var appState = BehaviorSubject<String>.seeded("/");

  // Live events log
  final gatewayEvents = BehaviorSubject<List<Map<String, dynamic>>>.seeded(const []);
  final loansEvents = BehaviorSubject<List<Map<String, dynamic>>>.seeded(const []);
  StreamSubscription? _gatewaySub;
  StreamSubscription? _loansSub;

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
    _gatewaySub?.cancel();
    _loansSub?.cancel();
    environment.close();
    scGatewayConfig.close();
    scLoanConfig.close();
    transactionID.close();
    gatewayEvents.close();
    loansEvents.close();
    _singleton = null;
  }
}

extension on SmartInvestingAppRepository {
  void _appendGatewayEvent(Map<String, dynamic> event) {
    final current = List<Map<String, dynamic>>.from(gatewayEvents.value);
    if (current.length >= 200) current.removeAt(0);
    current.add(event);
    gatewayEvents.add(current);
  }

  void _appendLoansEvent(Map<String, dynamic> event) {
    final current = List<Map<String, dynamic>>.from(loansEvents.value);
    if (current.length >= 200) current.removeAt(0);
    current.add(event);
    loansEvents.add(current);
  }
}
