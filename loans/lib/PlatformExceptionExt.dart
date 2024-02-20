import 'package:flutter/services.dart';

import 'ScLoanResponses.dart';

extension PlatformExceptionExt on PlatformException {
  ScLoanError get toScLoanError {
    return ScLoanError.fromJson(details);
  }
}