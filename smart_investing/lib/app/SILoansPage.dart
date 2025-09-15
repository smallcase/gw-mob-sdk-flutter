import 'dart:async';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:scloans/sc_loan.dart';
import 'package:scloans/sc_loan_events.dart';

import 'global/SmartInvestingAppRepository.dart';
import 'widgets/SIButton.dart';
import 'widgets/SIEnvironmentController.dart';
import 'widgets/SISwitch.dart';
import 'widgets/SIText.dart';
import 'widgets/SITextField.dart';
import 'package:flutter/widgets.dart';

// Loans Event data model
class ScLoanEventData {
  final String rawJson;
  final Map<String, dynamic>? parsedData;
  final String eventType;
  final DateTime timestamp;

  ScLoanEventData({
    required this.rawJson,
    required this.parsedData,
    required this.eventType,
    required this.timestamp,
  });

  factory ScLoanEventData.fromJson(String jsonString) {
    final parsedData = ScLoanEvents.parseEvent(jsonString);
    final eventType = parsedData?['event'] ?? parsedData?['type'] ?? 'unknown';

    return ScLoanEventData(
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
      case 'approved':
      case 'disbursed':
        return Colors.green.shade50;
      case 'error':
      case 'failed':
      case 'rejected':
      case 'cancelled':
        return Colors.red.shade50;
      case 'started':
      case 'initiated':
      case 'pending':
      case 'applied':
        return Colors.blue.shade50;
      case 'warning':
      case 'retry':
      case 'under_review':
        return Colors.orange.shade50;
      case 'info':
      case 'progress':
      case 'processing':
        return Colors.grey.shade50;
      default:
        return Colors.lightBlue.shade50;
    }
  }

  Color get borderColor {
    switch (eventType.toLowerCase()) {
      case 'success':
      case 'completed':
      case 'approved':
      case 'disbursed':
        return Colors.green.shade200;
      case 'error':
      case 'failed':
      case 'rejected':
      case 'cancelled':
        return Colors.red.shade200;
      case 'started':
      case 'initiated':
      case 'pending':
      case 'applied':
        return Colors.blue.shade200;
      case 'warning':
      case 'retry':
      case 'under_review':
        return Colors.orange.shade200;
      case 'info':
      case 'progress':
      case 'processing':
        return Colors.grey.shade200;
      default:
        return Colors.lightBlue.shade200;
    }
  }
}

class SILoansPage extends StatelessWidget {
  const SILoansPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SIText.xlarge(text: "LOANS"),
        actions: [
          SIButton(
            label: "Gateway",
            onPressed: () => {
              repository.appState.add("/"),
              context.go(repository.appState.value),
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 8),
          children: [
            SIEnvironmentController(repository: repository),
            StreamBuilder(
              stream: repository.scLoanConfig,
              builder: (context, snapshot) {
                final data = snapshot.data;
                if (data == null) {
                  return const SizedBox();
                }
                return Column(
                  children: [
                    SITextField(
                      hint: "Enter Gateway Name",
                      onChanged: (value) {
                        repository.scLoanConfig.value = data.copyWith(
                          gatewayName: value,
                        );
                      },
                    ),
                    SITextField(
                      hint: "Enter Custom Interaction Token",
                      onChanged: (value) {
                        repository.scLoanConfig.value = data.copyWith(
                          customInteractionToken: value,
                        );
                      },
                    ),
                  ],
                );
              },
            ),
            Wrap(
              spacing: 12,
              children: [
                SIButton(
                  label: "Setup",
                  onPressed: () async {
                    try {
                      final response = await ScLoan.setup(
                        ScLoanConfig(
                          repository.scLoanConfig.value.environment,
                          repository.scLoanConfig.value.gatewayName,
                        ),
                      );
                      repository.showAlertDialog(response.toString(), context);
                    } on ScLoanError catch (e) {
                      repository.showAlertDialog(e.toString(), context);
                    }
                  },
                ),
                SIButton(
                  label: "Apply",
                  onPressed: () async {
                    try {
                      final response = await ScLoan.apply(
                        ScLoanInfo(
                          repository
                                  .scLoanConfig
                                  .value
                                  .customInteractionToken ??
                              "",
                        ),
                      );
                      repository.showAlertDialog(response.toString(), context);
                    } on ScLoanError catch (e) {
                      repository.showAlertDialog(e.toString(), context);
                    }
                  },
                ),
                SIButton(
                  label: "Pay",
                  onPressed: () async {
                    try {
                      final response = await ScLoan.pay(
                        ScLoanInfo(
                          repository
                                  .scLoanConfig
                                  .value
                                  .customInteractionToken ??
                              "",
                        ),
                      );
                      repository.showAlertDialog(response.toString(), context);
                    } on ScLoanError catch (e) {
                      repository.showAlertDialog(e.toString(), context);
                    }
                  },
                ),
                SIButton(
                  label: "Withdraw",
                  onPressed: () async {
                    try {
                      final response = await ScLoan.withdraw(
                        ScLoanInfo(
                          repository
                                  .scLoanConfig
                                  .value
                                  .customInteractionToken ??
                              "",
                        ),
                      );
                      repository.showAlertDialog(response.toString(), context);
                    } on ScLoanError catch (e) {
                      repository.showAlertDialog(e.toString(), context);
                    }
                  },
                ),
                SIButton(
                  label: "Service",
                  onPressed: () async {
                    try {
                      final response = await ScLoan.service(
                        ScLoanInfo(
                          repository
                                  .scLoanConfig
                                  .value
                                  .customInteractionToken ??
                              "",
                        ),
                      );
                      repository.showAlertDialog(response.toString(), context);
                    } on ScLoanError catch (e) {
                      repository.showAlertDialog(e.toString(), context);
                    }
                  },
                ),
                SIButton(
                  label: "Trigger Interaction",
                  onPressed: () async {
                    try {
                      final response = await ScLoan.triggerInteraction(
                        ScLoanInfo(
                          repository
                                  .scLoanConfig
                                  .value
                                  .customInteractionToken ??
                              "",
                        ),
                      );
                      repository.showAlertDialog(response.toString(), context);
                    } on ScLoanError catch (e) {
                      repository.showAlertDialog(e.toString(), context);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            _EnhancedLoansEventsList(),
            StreamBuilder(
              stream: repository.siConfig,
              builder: (context, snapshot) {
                final data = snapshot.data;
                return Wrap(
                  children: [
                    SITextField(
                      text: data?.loansUserId,
                      hint: "Enter SI user Id",
                    ),
                    SIButton(label: "Get User"),
                  ],
                );
              },
            ),
            SIText.large(text: "Create a New User"),
            Wrap(
              children: [
                SITextField(hint: "Enter new user Id"),
                SITextField(hint: "Enter PAN"),
                SITextField(hint: "Enter DOB"),
                SITextField(hint: "Enter Email"),
                SITextField(hint: "Enter Phone"),
                SITextField(hint: "Enter Bank Acc. no."),
                SITextField(hint: "Enter IFSC code"),
                SITextField(hint: "Enter Account Type"),
                SITextField(hint: "Enter MF Holdings Json"),
                SISwitch(
                  label: "Enable Lien Marking",
                  isEnabled: false,
                  onChanged: (value) {},
                ),
              ],
            ),
            SIButton(label: "Register"),
          ],
        ),
      ),
    );
  }
}

class _EnhancedLoansEventsList extends StatefulWidget {
  @override
  State<_EnhancedLoansEventsList> createState() =>
      _EnhancedLoansEventsListState();
}

class _EnhancedLoansEventsListState extends State<_EnhancedLoansEventsList> {
  StreamSubscription<String>? _scLoanEventsSubscription;
  final List<ScLoanEventData> _scLoanEvents = [];

  @override
  void initState() {
    super.initState();
    _setupScLoanEvents();
  }

  void _setupScLoanEvents() {
    // Start listening to loan events
    ScLoanEvents.startListening();

    _scLoanEventsSubscription = ScLoanEvents.eventStream.listen((jsonString) {
      setState(() {
        // Parse the event data
        final eventData = ScLoanEventData.fromJson(jsonString);
        _scLoanEvents.insert(0, eventData);
        if (_scLoanEvents.length > 20) {
          _scLoanEvents.removeLast();
        }
      });
    });
  }

  @override
  void dispose() {
    _scLoanEventsSubscription?.cancel();
    ScLoanEvents.stopListening();
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
                  'Loans Events (live)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.delete_outline),
                      onPressed: () {
                        setState(() {
                          _scLoanEvents.clear();
                        });
                      },
                      tooltip: 'Clear Events',
                    ),
                    Text('${_scLoanEvents.length}'),
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
              child: _scLoanEvents.isEmpty
                  ? Center(
                      child: Text(
                        'No Loans events yet...',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _scLoanEvents.length,
                      itemBuilder: (context, index) {
                        final eventData = _scLoanEvents[index];
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
                                    '${_scLoanEvents.length - index}',
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
