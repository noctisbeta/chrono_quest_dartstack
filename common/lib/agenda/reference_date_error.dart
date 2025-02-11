enum ReferenceDateError {
  notFound,
  unknown;

  factory ReferenceDateError.fromString(String value) => switch (value) {
        'notFound' => ReferenceDateError.notFound,
        'unknown' => ReferenceDateError.unknown,
        _ => throw ArgumentError('Invalid ReferenceDateError value: $value'),
      };

  @override
  String toString() => switch (this) {
        ReferenceDateError.notFound => 'notFound',
        ReferenceDateError.unknown => 'unknown',
      };
}
