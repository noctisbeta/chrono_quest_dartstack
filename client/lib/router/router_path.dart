enum RouterPath {
  auth,
  agenda;

  String get path {
    switch (this) {
      case RouterPath.auth:
        return '/auth';
      case RouterPath.agenda:
        return '/agenda';
    }
  }

  String get name {
    switch (this) {
      case RouterPath.auth:
        return 'auth';
      case RouterPath.agenda:
        return 'agenda';
    }
  }
}
