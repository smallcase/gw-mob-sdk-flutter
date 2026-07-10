// ignore: constant_identifier_names
enum ScLoanEnvironment { DEVELOPMENT, PRODUCTION, STAGING }

enum ScLoanColorScheme { dark, light, system }

class ScLoanConfig {
  final ScLoanEnvironment environment;
  final String gateway;

  const ScLoanConfig(this.environment, this.gateway);
}

class ScLoanInfo {
  final String interactionToken;
  final ScLoanColorScheme? colorScheme;

  const ScLoanInfo(this.interactionToken, {this.colorScheme});
}
