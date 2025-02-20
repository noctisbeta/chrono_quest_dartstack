enum Environment {
  development,
  staging,
  production;

  bool get isDevelopment => this == Environment.development;
  bool get isStaging => this == Environment.staging;
  bool get isProduction => this == Environment.production;
}

class ServerConfig {
  const ServerConfig({
    required this.useHttps,
    required this.certPath,
    required this.keyPath,
    required this.port,
    required this.host,
    required this.environment,
  });

  factory ServerConfig.development() => const ServerConfig(
    useHttps: false,
    certPath: '',
    keyPath: '',
    port: 8080,
    host: 'localhost',
    environment: Environment.development,
  );

  factory ServerConfig.staging() => const ServerConfig(
    useHttps: true,
    certPath: 'certificates/staging/fullchain.pem',
    keyPath: 'certificates/staging/privkey.pem',
    port: 8080,
    host: 'staging.yourapp.com',
    environment: Environment.staging,
  );

  factory ServerConfig.production() => const ServerConfig(
    useHttps: true,
    certPath: 'certificates/production/fullchain.pem',
    keyPath: 'certificates/production/privkey.pem',
    port: 443,
    host: 'yourapp.com',
    environment: Environment.production,
  );
  final bool useHttps;
  final String certPath;
  final String keyPath;
  final int port;
  final String host;
  final Environment environment;
}
