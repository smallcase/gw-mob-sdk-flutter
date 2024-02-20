
import 'dart:async';

import 'package:flutter/services.dart';

class Loans {
  static const MethodChannel _channel = MethodChannel('loans');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
