import 'dart:convert';


import 'package:scgateway_flutter_plugin/scgateway_flutter_plugin.dart';
import 'package:scloans/ScLoanProps.dart';

enum SIEnvironment {
  PRODUCTION(label: "Prod"),
  DEVELOPMENT(label: "Dev"),
  STAGING(label: "Stag");

  final String label;

  const SIEnvironment({required this.label});

  ({ScGatewayConfig scGatewayConfig, ScLoanConfig scLoanConfig}) get _configs {
    switch (this) {
      case SIEnvironment.PRODUCTION:
        return (
          scGatewayConfig: ScGatewayConfig.prod(),
          scLoanConfig: ScLoanConfig.prod()
        );
      case SIEnvironment.DEVELOPMENT:
        return (
          scGatewayConfig: ScGatewayConfig.dev(),
          scLoanConfig: ScLoanConfig.dev()
        );
      case SIEnvironment.STAGING:
        return (
          scGatewayConfig: ScGatewayConfig.stag(),
          scLoanConfig: ScLoanConfig.stag()
        );
    }
  }

  ScGatewayConfig get scGatewayConfig {
    return _configs.scGatewayConfig;
  }

  ScLoanConfig get scLoanConfig {
    return _configs.scLoanConfig;
  }
}

class SIConfig {
  final String? gatewayUserId;
  final String? loansUserId;

  SIConfig({this.gatewayUserId, this.loansUserId});

  SIConfig copyWith({
    String? gatewayUserId,
    String? loansUserId,
  }) {
    return SIConfig(
      gatewayUserId: gatewayUserId ?? this.gatewayUserId,
      loansUserId: loansUserId ?? this.loansUserId,
    );
  }
}

class ScGatewayConfig {
  final GatewayEnvironment environment;
  final String gatewayName;
  final String? customAuthToken;
  final bool isLeprechaunEnabled;
  final bool isAmoEnabled;
  final String? transactionId;

  const ScGatewayConfig({
    required this.gatewayName,
    required this.environment,
    this.customAuthToken = null,
    this.isLeprechaunEnabled = false,
    this.isAmoEnabled = false,
    this.transactionId
  });

  factory ScGatewayConfig.prod() => ScGatewayConfig(
      gatewayName: "gatewaydemo", environment: GatewayEnvironment.PRODUCTION);
  factory ScGatewayConfig.dev() => ScGatewayConfig(
      gatewayName: "gatewaydemo-dev",
      environment: GatewayEnvironment.DEVELOPMENT);
  factory ScGatewayConfig.stag() => ScGatewayConfig(
      gatewayName: "gatewaydemo-stag", environment: GatewayEnvironment.STAGING);

  Map<String, dynamic> toMap() {
    return {
      'environment': environment.name,
      'gatewayName': gatewayName,
    };
  }

  factory ScGatewayConfig.fromMap(Map<String, dynamic> map) {
    return ScGatewayConfig(
      environment: GatewayEnvironment.values
          .firstWhere((element) => element.name == map['environment']),
      gatewayName: map['gatewayName'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory ScGatewayConfig.fromJson(String source) =>
      ScGatewayConfig.fromMap(json.decode(source));

  ScGatewayConfig copyWith({
    GatewayEnvironment? environment,
    String? gatewayName,
    String? customAuthToken,
    bool? isLeprechaunEnabled,
    bool? isAmoEnabled,
  }) {
    return ScGatewayConfig(
      environment: environment ?? this.environment,
      gatewayName: gatewayName ?? this.gatewayName,
      customAuthToken: customAuthToken ?? this.customAuthToken,
      isLeprechaunEnabled: isLeprechaunEnabled ?? this.isLeprechaunEnabled,
      isAmoEnabled: isAmoEnabled ?? this.isAmoEnabled,
    );
  }
}

class ScLoanConfig {
  final ScLoanEnvironment environment;
  final String gatewayName;
  final String? customInteractionToken;

  const ScLoanConfig({
    required this.gatewayName,
    required this.environment,
    this.customInteractionToken,
  });

  factory ScLoanConfig.prod() => ScLoanConfig(
      gatewayName: "gatewaydemo", environment: ScLoanEnvironment.PRODUCTION);
  factory ScLoanConfig.dev() => ScLoanConfig(
      gatewayName: "gatewaydemo-dev",
      environment: ScLoanEnvironment.DEVELOPMENT);
  factory ScLoanConfig.stag() => ScLoanConfig(
      gatewayName: "gatewaydemo-stag", environment: ScLoanEnvironment.STAGING);

  Map<String, dynamic> toMap() {
    return {
      'environment': environment.name,
      'gatewayName': gatewayName,
    };
  }

  factory ScLoanConfig.fromMap(Map<String, dynamic> map) {
    return ScLoanConfig(
      environment: ScLoanEnvironment.values
          .firstWhere((element) => element.name == map['environment']),
      gatewayName: map['gatewayName'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory ScLoanConfig.fromJson(String source) =>
      ScLoanConfig.fromMap(json.decode(source));

  @override
  String toString() =>
      'ScLoanConfig(environment: $environment, gatewayName: $gatewayName)';

  ScLoanConfig copyWith({
    ScLoanEnvironment? environment,
    String? gatewayName,
  }) {
    return ScLoanConfig(
      environment: environment ?? this.environment,
      gatewayName: gatewayName ?? this.gatewayName,
    );
  }
}
