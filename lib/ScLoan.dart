import 'package:flutter/services.dart';

enum SCLoanEnvironment { PRODUCTION, DEVELOPMENT, STAGING }

class SCLoans {
  static const MethodChannel _channel =
      const MethodChannel('scloans_flutter_plugin');

  static Future<String?> setup(
    SCLoanEnvironment environment,
    String gateway,
  ) async {
    String? setupResponse;

    try {
      setupResponse = await _channel.invokeMethod('setup',
          <String, dynamic>{"gateway": gateway, "env": environment.index});
    } on PlatformException catch (e) {
      setupResponse = e.code;
    }

    return setupResponse;
  }

  static Future<String?> apply(
    String interactionToken,
  ) async {
    String? applyResponse;

    try {
      applyResponse = await _channel.invokeMethod('apply', <String, dynamic>{
        "interactionToken": interactionToken,
      });
    } on PlatformException catch (e) {
      applyResponse = e.code;
    }

    return applyResponse;
  }

  static Future<String?> pay(
    String interactionToken,
  ) async {
    String? payResponse;

    try {
      payResponse = await _channel.invokeMethod('pay', <String, dynamic>{
        "interactionToken": interactionToken,
      });
    } on PlatformException catch (e) {
      payResponse = e.code;
    }

    return payResponse;
  }

  static Future<String?> withdraw(
    String interactionToken,
  ) async {
    String? withdrawResponse;

    try {
      withdrawResponse =
          await _channel.invokeMethod('withdraw', <String, dynamic>{
        "interactionToken": interactionToken,
      });
    } on PlatformException catch (e) {
      withdrawResponse = e.code;
    }

    return withdrawResponse;
  }

  static Future<String?> service(
    String interactionToken,
  ) async {
    String? serviceResponse;

    try {
      serviceResponse =
          await _channel.invokeMethod('service', <String, dynamic>{
        "interactionToken": interactionToken,
      });
    } on PlatformException catch (e) {
      serviceResponse = e.code;
    }

    return serviceResponse;
  }
}
