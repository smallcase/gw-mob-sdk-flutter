import 'package:hive/hive.dart';

import '../global/SIConfigs.dart';


class SICache {
  final _scGatewayConfigBox = Hive.box('scGatewayConfig');
  final _scLoanConfigBox = Hive.box('scLoanConfig');

  void setScGatewayConfig(ScGatewayConfig config) {
    _scGatewayConfigBox.putAll(config.toMap());
  }

  void setScLoanConfigBox(ScLoanConfig config) {
    _scLoanConfigBox.putAll(config.toMap());
  }
}
