import 'package:flutter/services.dart';

import 'sc_loan_responses.dart';

extension PlatformExceptionExt on PlatformException {
  ScLoanError get toScLoanError {
    return ScLoanError.fromJson(details);
  }
}