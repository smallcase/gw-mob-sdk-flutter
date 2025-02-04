import 'package:flutter/material.dart';
import 'package:sdk_core/anubhav/configuration/anubhavconfiguration.dart';
import 'package:sdk_core/anubhav/events/anubhavevent.dart';
import 'package:sdk_core/anubhav/finarkein.dart';
import 'package:sdk_core/anubhav/result/anubhavexit.dart';
import 'package:sdk_core/anubhav/result/anubhavresult.dart';
import 'package:sdk_core/anubhav/result/anubhavsuccess.dart';
import 'package:sdk_core/internal/anubhav.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AnubhavScreen extends StatefulWidget {
  @override
  _AnubhavScreenState createState() => _AnubhavScreenState();
}

class _AnubhavScreenState extends State<AnubhavScreen> {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _panController = TextEditingController();
  
  String? _requestId;
  String? _redirectUrl;
  bool _loading = false;
  bool _startAnubhav = false;
  List<Map<String, dynamic>> _eventLogs = [];

  Future<void> _fetchRequestDetails() async {
    if (_userIdController.text.isEmpty || _phoneController.text.isEmpty || _panController.text.isEmpty) {
      _showAlert("Invalid Input", "Please enter User ID, Phone, and PAN");
      return;
    }

    setState(() => _loading = true);

    try {
      final response = await http.post(
        Uri.parse('https://gw-aa-stag.smallcase.com/v1/internal/vendor/journey'),
        headers: {
          'x-client-id': 'gatewayDemo',
          'x-api-key': 'aee22d5b-206c-4ae9-8410-7bb272e10049',
          'x-flow-name': 'wealth_office',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'userId': _userIdController.text,
          'phone': _phoneController.text,
          'pan': _panController.text,
        }),
      );

      final data = jsonDecode(response.body);
      setState(() => _loading = false);

      if (data['success'] == true) {
        final vendorData = data['data']['vendorData'];
        if (vendorData != null) {
          setState(() {
            _requestId = vendorData['requestId'];
            _redirectUrl = vendorData['redirectUrl'];
          });
          _showAlert("Success", "Request ID and Redirect URL fetched successfully.");
        } else {
          _showAlert("Error", "Vendor Data is missing in response.");
        }
      } else {
        _showAlert("API Error", "Failed to fetch data.");
      }
    } catch (error) {
      setState(() => _loading = false);
      _showAlert("API Error", "Something went wrong.");
    }
  }

void _startAnubhavSDK() {
  if (_requestId == null || _redirectUrl == null) {
    _showAlert("Invalid Input", "Request ID and Redirect URL are required.");
    return;
  }

  // Ensure the event listener is registered before launching SDK
Finarkein.setEventListener((AnubhavEvent event) {
  try {
    print("Event received: ${event.name}");
    _logEvent(event.name, event.metadata);
  } catch (e) {
    print("Error processing event: $e");
  }
});


  final anubhavConfig = AnubhavConfiguration.withWebViewUrl(_redirectUrl!)
      .requestId(_requestId!)
      .build();

  // Use a Future to allow the listener to initialize properly
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Anubhav(
          anubhavConfiguration: anubhavConfig,
          onSuccess: _handleResult,
          onExit: _handleResult,
        ),
      ),
    );
}

  void _handleResult(AnubhavResult result) {
    if (result is AnubhavSuccess) {
      _logEvent("Success", result.metadata);
    } else if (result is AnubhavExit) {
      _logEvent("Exit", result.metadata);
    }
  }

  void _logEvent(String name, dynamic metadata) {
    setState(() {
      _eventLogs.add({
        "timestamp": DateTime.now().toIso8601String(),
        "name": name,
        "metadata": metadata,
      });
    });
  }

  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text("Anubhav Integration")),
    body: SingleChildScrollView(  // 🔹 Makes the entire screen scrollable
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _userIdController,
                  decoration: InputDecoration(labelText: "Enter User ID"),
                ),
                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: "Enter Phone"),
                  keyboardType: TextInputType.phone,
                ),
                TextField(
                  controller: _panController,
                  decoration: InputDecoration(labelText: "Enter PAN"),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _loading ? null : _fetchRequestDetails,
                  child: _loading ? CircularProgressIndicator() : Text("Fetch API Data"),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: TextEditingController(text: _requestId),
                  decoration: InputDecoration(labelText: "Request ID"),
                  readOnly: true,
                ),
                TextField(
                  controller: TextEditingController(text: _redirectUrl),
                  decoration: InputDecoration(labelText: "Redirect URL"),
                  readOnly: true,
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: (_requestId == null || _redirectUrl == null) ? null : _startAnubhavSDK,
                  child: Text("Launch Anubhav"),
                ),
                SizedBox(height: 20),
                Text("Event Logs", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Container(
            height: 300,  // 🔹 Set a fixed height to make it properly scrollable
            child: ListView.builder(
              shrinkWrap: true,  // 🔹 Prevents errors due to infinite height
              physics: AlwaysScrollableScrollPhysics(), // 🔹 Ensures scrolling works
              itemCount: _eventLogs.length,
              itemBuilder: (context, index) {
                final log = _eventLogs[index];
                return ListTile(
                  title: Text(log["name"]),
                  subtitle: Text(jsonEncode(log["metadata"])),
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