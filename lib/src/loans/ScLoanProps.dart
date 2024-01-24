import 'dart:convert';

enum ScLoanEnvironment { DEVELOPMENT, PRODUCTION, STAGING }


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



class ScLoanInfo {
  final String interactionToken;

  const ScLoanInfo(this.interactionToken);
}