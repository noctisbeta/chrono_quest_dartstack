enum ContextKey {
  userId('userId'),
  healthService('healthService'),
  postgresService('postgresService'),
  migrationService('migrationService'),
  agendaRepository('agendaRepository'),
  agendaHandler('agendaHandler'),
  agendaDataSource('agendaDataSource'),
  authRepository('authRepository'),
  authHandler('authHandler'),
  authDataSource('authDataSource');

  const ContextKey(this.keyString);

  final String keyString;
}
