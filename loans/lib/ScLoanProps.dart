enum ScLoanEnvironment { DEVELOPMENT, PRODUCTION, STAGING }

class ScLoanConfig {
  final ScLoanEnvironment environment;
  final String gateway;

  const ScLoanConfig(this.environment, this.gateway);
}

class ScLoanInfo {
  final String interactionToken;

  const ScLoanInfo(this.interactionToken);
}