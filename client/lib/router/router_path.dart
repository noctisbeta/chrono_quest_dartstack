enum RouterPath {
  auth('/auth'),
  agenda('/agenda'),
  encryption('/encryption'),
  cycles('cycles'),
  addCycle('add-cycle'),
  overview('overview');

  const RouterPath(this.path);

  final String path;

  String get name => toString().split('.').last;

  String Function(Map<String, String> params)? get pathWithParams =>
      path.contains(':')
          ? (params) => path.replaceAllMapped(RegExp(r':(\w+)'), (match) {
                final String paramName = match.group(1)!;
                return params[paramName] ?? '';
              })
          : null;
}
