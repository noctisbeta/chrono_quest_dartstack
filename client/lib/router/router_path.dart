enum RouterPath {
  auth('/auth'),
  encryption('/encryption'),
  agenda('/agenda'),
  agendaCycles('/agenda/cycles'),
  agendaAddCycle('/agenda/add-cycle'),
  agendaOverview('/agenda/overview');

  const RouterPath(this.path);

  final String path;

  String get name => toString().split('.').last;

  String get subPath => path.split('/').last;
}
