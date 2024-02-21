import 'package:flutter/services.dart';
import 'ScLoanProps.dart';
import 'ScLoanResponses.dart';
import '../PlatformExceptionExt.dart';
export '../ScLoan.dart';
export '../ScLoanResponses.dart';
export '../ScLoanProps.dart';

class ScLoan {
  static const MethodChannel _channel =
      const MethodChannel('scloans');

  static Future<ScLoanSuccess> setup(ScLoanConfig config) async {
    try {
      String? setupResponse = await _channel.invokeMethod(
          'setup', <String, dynamic>{
        "gateway": config.gateway,
        "env": config.environment.index
      });
      return ScLoanSuccess.fromJson(setupResponse ?? "{}");
    } on PlatformException catch (e) {
      throw e.toScLoanError;
    }
  }

  static Future<ScLoanSuccess> apply(ScLoanInfo loanInfo) async {
    try {
      String? applyResponse =
          await _channel.invokeMethod('apply', <String, dynamic>{
        "interactionToken": loanInfo.interactionToken,
      });
      return ScLoanSuccess.fromJson(applyResponse ?? "{}");
    } on PlatformException catch (e) {
      throw e.toScLoanError;
    }
  }

  static Future<ScLoanSuccess> pay(ScLoanInfo loanInfo) async {
    try {
      String? payResponse =
          await _channel.invokeMethod('pay', <String, dynamic>{
        "interactionToken": loanInfo.interactionToken,
      });
      return ScLoanSuccess.fromJson(payResponse ?? "{}");
    } on PlatformException catch (e) {
      throw e.toScLoanError;
    }
  }

  static Future<ScLoanSuccess> withdraw(ScLoanInfo loanInfo) async {
    try {
      String? withdrawResponse =
          await _channel.invokeMethod('withdraw', <String, dynamic>{
        "interactionToken": loanInfo.interactionToken,
      });
      return ScLoanSuccess.fromJson(withdrawResponse ?? "{}");
    } on PlatformException catch (e) {
      throw e.toScLoanError;
    }
  }

  static Future<ScLoanSuccess> service(ScLoanInfo loanInfo) async {
    try {
      String? serviceResponse =
          await _channel.invokeMethod('service', <String, dynamic>{
        "interactionToken": loanInfo.interactionToken,
      });
      return ScLoanSuccess.fromJson(serviceResponse ?? "{}");
    } on PlatformException catch (e) {
      throw e.toScLoanError;
    }
  }
}
