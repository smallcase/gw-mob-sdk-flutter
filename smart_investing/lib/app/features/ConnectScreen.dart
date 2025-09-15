import 'dart:async';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:scgateway_flutter_plugin/scgateway_flutter_plugin.dart';
import 'package:scgateway_flutter_plugin/scgateway_events.dart';

import '../../smartinvesting.dart';
import '../global/SIConfigs.dart';
import '../global/SmartInvestingAppRepository.dart';
import '../widgets/SIButton.dart';
import '../widgets/SIEnvironmentController.dart';
import '../widgets/SISwitch.dart';
import '../widgets/SIText.dart';
import '../widgets/SITextField.dart';

final gatewayEnvironments = [
  ScGatewayConfig.prod(),
  ScGatewayConfig.dev(),
  ScGatewayConfig.stag(),
];

SmartInvesting smartInvesting = SmartInvestingAppRepository.smartInvesting;

// Event data model
class ScGatewayEventData {
  final String rawJson;
  final Map<String, dynamic>? parsedData;
  final String eventType;
  final DateTime timestamp;

  ScGatewayEventData({
    required this.rawJson,
    required this.parsedData,
    required this.eventType,
    required this.timestamp,
  });

  factory ScGatewayEventData.fromJson(String jsonString) {
    final parsedData = ScgatewayEvents.parseEvent(jsonString);
    final eventType = parsedData?['event'] ?? parsedData?['type'] ?? 'unknown';

    return ScGatewayEventData(
      rawJson: jsonString,
      parsedData: parsedData,
      eventType: eventType.toString(),
      timestamp: DateTime.now(),
    );
  }

  Color get backgroundColor {
    switch (eventType.toLowerCase()) {
      case 'success':
      case 'completed':
      case 'transaction_completed':
        return Colors.green.shade50;
      case 'error':
      case 'failed':
      case 'transaction_failed':
        return Colors.red.shade50;
      case 'started':
      case 'initiated':
      case 'transaction_started':
        return Colors.blue.shade50;
      case 'warning':
      case 'retry':
        return Colors.orange.shade50;
      case 'info':
      case 'progress':
        return Colors.grey.shade50;
      default:
        return Colors.lightBlue.shade50;
    }
  }

  Color get borderColor {
    switch (eventType.toLowerCase()) {
      case 'success':
      case 'completed':
      case 'transaction_completed':
        return Colors.green.shade200;
      case 'error':
      case 'failed':
      case 'transaction_failed':
        return Colors.red.shade200;
      case 'started':
      case 'initiated':
      case 'transaction_started':
        return Colors.blue.shade200;
      case 'warning':
      case 'retry':
        return Colors.orange.shade200;
      case 'info':
      case 'progress':
        return Colors.grey.shade200;
      default:
        return Colors.lightBlue.shade200;
    }
  }
}

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 8),
      children: [
        SIEnvironmentController(repository: repository),
        StreamBuilder(
          stream: repository.scGatewayConfig,
          builder: (context, snapshot) {
            final data = snapshot.data;
            if (data == null)
              return Text("scGatewayConfig is not set in ${repository}");
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SITextField(hint: "Enter gateway name", text: data.gatewayName),
                SISwitch(
                  label: "Leprechaun Mode:",
                  isEnabled: data.isLeprechaunEnabled,
                  onChanged: (value) {
                    repository.scGatewayConfig.value = data.copyWith(
                      isLeprechaunEnabled: value,
                    );
                  },
                ),
                SISwitch(
                  label: "Amo Mode:",
                  isEnabled: data.isAmoEnabled,
                  onChanged: (value) {
                    repository.scGatewayConfig.value = data.copyWith(
                      isAmoEnabled: value,
                    );
                  },
                ),
                SITextField(
                  hint: "Smart Investing User Id",
                  onChanged: (value) {
                    repository.smartInvestingUserId.add(value);
                  },
                ),
                SIButton(
                  label: "Fetch AuthToken From SmartInvesting",
                  onPressed: () async {
                    print(
                      "THE SMARTINVESTING USER ID INSIDE FETCH AUTH TOKEN IS ${repository.smartInvestingUserId.value}",
                    );
                    final loginResponse = await smartInvesting.userLogin(
                      userID: repository.smartInvestingUserId.value,
                    );
                    repository.scGatewayConfig.value = data.copyWith(
                      customAuthToken: loginResponse["smallcaseAuthToken"],
                    );
                    repository.showAlertDialog(
                      loginResponse.toString(),
                      context,
                    );
                  },
                ),
                SITextField(
                  hint: "Custom Auth Token (JwT)",
                  text: data.customAuthToken,
                  onChanged: (value) {
                    repository.scGatewayConfig.value = data.copyWith(
                      customAuthToken: value,
                    );
                  },
                ),
                Wrap(
                  children: [
                    SIButton(
                      label: "SETUP",
                      onPressed: () async {
                        await ScgatewayFlutterPlugin.setConfigEnvironment(
                          repository.scGatewayConfig.value.environment,
                          repository.scGatewayConfig.value.gatewayName,
                          repository.scGatewayConfig.value.isLeprechaunEnabled,
                          [],
                          isAmoenabled:
                              repository.scGatewayConfig.value.isAmoEnabled,
                        );
                        if (repository.scGatewayConfig.value.customAuthToken ==
                            null) {
                          final loginResponse = await smartInvesting.userLogin(
                            userID: repository.smartInvestingUserId.value,
                          );
                          repository.scGatewayConfig.value = data.copyWith(
                            customAuthToken:
                                loginResponse["smallcaseAuthToken"],
                          );
                        }
                        final initResponse =
                            await ScgatewayFlutterPlugin.initGateway(
                              repository
                                      .scGatewayConfig
                                      .value
                                      .customAuthToken ??
                                  "",
                            );
                        repository.showAlertDialog(
                          initResponse.toString(),
                          context,
                        );
                      },
                    ),
                    SIButton(
                      label: "CONNECT",
                      onPressed: () async {
                        // final transactionId =
                        //     await SmartInvesting.fromEnvironment(
                        //             repository.scGatewayConfig.value)
                        //         .getTransactionId(
                        //             repository.smartInvestingUserId.value ?? "",
                        //             ScgatewayIntent.CONNECT,
                        //             null);
                        // final response = await ScgatewayFlutterPlugin
                        //         .triggerGatewayTransaction(transactionId) ??
                        //     "";
                        // repository.showAlertDialog(
                        //     response.toString(), context);
                        repository.triggerTransaction(
                          ScgatewayIntent.CONNECT,
                          null,
                          false,
                          context,
                        );
                      },
                    ),
                  ],
                ),
                SizedBox.square(dimension: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SIText.large(text: "Trigger Txn with Id"),
                    InputChip(
                      checkmarkColor: Colors.white,
                      onSelected: (value) {
                        repository.scGatewayConfig.value = data.copyWith(
                          isMFTransactionEnabled: value,
                        );
                      },
                      label: Text("MF"),
                      selected: data.isMFTransactionEnabled,
                      elevation: 0,
                      selectedColor: Colors.green,
                    ),
                  ],
                ),
                SITextField(
                  hint: "Enter Transaction Id",
                  onChanged: (value) {
                    repository.transactionID.add(value);
                  },
                ),
                Wrap(
                  children: [
                    SIButton(
                      label: "Copy",
                      onPressed: () {
                        FlutterClipboard.copy(repository.transactionID.value);
                      },
                    ),
                    SIButton(
                      label: "Trigger",
                      onPressed: () {
                        repository.triggerTransaction(
                          null,
                          null,
                          true,
                          context,
                          isMF: data.isMFTransactionEnabled,
                        );
                      },
                    ),
                    SIButton(
                      label: "Search Postback",
                      onPressed: () {
                        //call the postback function here
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20),
                _EnhancedScGatewayEventsList(),
              ],
            );
          },
        ),
      ],
    );
  }

}

class _EnhancedScGatewayEventsList extends StatefulWidget {
  @override
  State<_EnhancedScGatewayEventsList> createState() =>
      _EnhancedScGatewayEventsListState();
}

class _EnhancedScGatewayEventsListState extends State<_EnhancedScGatewayEventsList> {
  StreamSubscription<String>? _scGatewayEventsSubscription;
  final List<ScGatewayEventData> _scGatewayEvents = [];

  @override
  void initState() {
    super.initState();
    _setupScGatewayEvents();
  }

  void _setupScGatewayEvents() {
    // Start listening to gateway events
    ScgatewayEvents.startListening();
    
    _scGatewayEventsSubscription = ScgatewayEvents.eventStream.listen((jsonString) {
      setState(() {
        // Parse the event data
        final eventData = ScGatewayEventData.fromJson(jsonString);
        _scGatewayEvents.insert(0, eventData);
        if (_scGatewayEvents.length > 20) {
          _scGatewayEvents.removeLast();
        }
      });
    });
  }

  @override
  void dispose() {
    _scGatewayEventsSubscription?.cancel();
    ScgatewayEvents.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ScGateway Events',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.delete_outline),
                      onPressed: () {
                        setState(() {
                          _scGatewayEvents.clear();
                        });
                      },
                      tooltip: 'Clear Events',
                    ),
                    Text('${_scGatewayEvents.length}'),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8),
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: _scGatewayEvents.isEmpty
                  ? Center(
                      child: Text(
                        'No ScGateway events yet...',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _scGatewayEvents.length,
                      itemBuilder: (context, index) {
                        final eventData = _scGatewayEvents[index];
                        return Container(
                          padding: EdgeInsets.all(8),
                          margin: EdgeInsets.symmetric(vertical: 2),
                          decoration: BoxDecoration(
                            color: eventData.backgroundColor,
                            border: Border.all(
                              color: eventData.borderColor,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Event header with type and number
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: eventData.borderColor,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      eventData.eventType.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    '${_scGatewayEvents.length - index}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: eventData.borderColor,
                                    ),
                                  ),
                                  Spacer(),
                                  IconButton(
                                    icon: Icon(Icons.copy, size: 16),
                                    onPressed: () {
                                      FlutterClipboard.copy(eventData.rawJson);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text('Event copied!'),
                                        ),
                                      );
                                    },
                                    tooltip: 'Copy Raw JSON',
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              // Event data (parsed or raw)
                              if (eventData.parsedData != null) ...[
                                // Show parsed data in a structured way
                                for (final entry
                                    in eventData.parsedData!.entries)
                                  if (entry.key != 'event' &&
                                      entry.key != 'type')
                                    Padding(
                                      padding: EdgeInsets.only(
                                        left: 16,
                                        bottom: 2,
                                      ),
                                      child: RichText(
                                        text: TextSpan(
                                          style: TextStyle(
                                            fontFamily: 'monospace',
                                            fontSize: 11,
                                            color: Colors.black87,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: '${entry.key}: ',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.blue[800],
                                              ),
                                            ),
                                            TextSpan(
                                              text: entry.value.toString(),
                                              style: TextStyle(
                                                color: Colors.grey[800],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                              ] else
                                // Show raw JSON if parsing failed
                                Padding(
                                  padding: EdgeInsets.only(left: 16),
                                  child: SelectableText(
                                    eventData.rawJson,
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 11,
                                      color: Colors.red[700],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
