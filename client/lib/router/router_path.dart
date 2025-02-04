enum RouterPath {
  auth,
  agenda,
  encryption;

  String get path {
    switch (this) {
      case RouterPath.auth:
        return '/auth';
      case RouterPath.agenda:
        return '/agenda';
      case RouterPath.encryption:
        return '/encryption';
    }
  }

  String get name {
    switch (this) {
      case RouterPath.auth:
        return 'auth';
      case RouterPath.agenda:
        return 'agenda';
      case RouterPath.encryption:
        return 'encryption';
    }
  }
}
