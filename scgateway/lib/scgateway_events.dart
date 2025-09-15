import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';

class ScgatewayEvents {
  static const EventChannel _eventChannel = EventChannel('scgateway_events');
  static StreamSubscription<dynamic>? _subscription;
  static final StreamController<String> _eventController =
      StreamController<String>.broadcast();

  /// Stream of SCGateway events (raw JSON strings)
  static Stream<String> get eventStream => _eventController.stream;

  /// Start listening to SCGateway events
  static void startListening() {
    if (_subscription != null) return;

    _subscription = _eventChannel.receiveBroadcastStream().listen(
      (dynamic event) {
        if (event is String) {
          print('SCGateway event stream: $event');
          _eventController.add(event);
        }
      },
      onError: (dynamic error) {
        print('SCGateway event stream error: $error');
      },
    );
  }

  /// Stop listening to SCGateway events
  static void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  /// Dispose resources
  static void dispose() {
    stopListening();
    _eventController.close();
  }

  /// Parse event data from JSON string
  static Map<String, dynamic>? parseEvent(String jsonString) {
    try {
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      print('Error parsing event JSON: $e');
      return null;
    }
  }
}
