import 'package:flutter/services.dart';

import '../loans/ScLoanResponses.dart';

extension PlatformExceptionExt on PlatformException {
  ScLoanError get toScLoanError {
    return ScLoanError.fromJson(details);
  }
}