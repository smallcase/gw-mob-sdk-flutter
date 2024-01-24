import 'package:hive/hive.dart';
import 'package:scgateway_flutter_plugin/scgateway_flutter_plugin.dart';
import 'package:scgateway_flutter_plugin_example/app/global/SIConfigs.dart';

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
