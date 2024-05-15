import 'package:flutter/services.dart';
import 'sc_loan_props.dart';
import 'sc_loan_responses.dart';
import 'platform_exception_ext.dart';
export 'sc_loan.dart';
export 'sc_loan_responses.dart';
export 'sc_loan_props.dart';

class ScLoan {
  static const _channel = MethodChannel('scloans');

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
