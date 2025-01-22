import 'package:common/exceptions/bad_map_shape_exception.dart';
import 'package:common/requests/request.dart';
import 'package:meta/meta.dart';

@immutable
final class User extends Model {
  const User({
    required this.id,
    required this.username,
    required this.displayName,
  });

  factory User.validatedFromMap(Map<String, dynamic> map) => switch (map) {
        {
          'id': final int id,
          'username': final String username,
          'display_name': final String? displayName,
        } =>
          User(
            id: id,
            username: username,
            displayName: displayName,
          ),
        _ => throw const BadMapShapeException(
            'Invalid map format for User',
          ),
      };

  final int id;
  final String username;
  final String? displayName;

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'username': username,
        'display_name': displayName,
      };

  @override
  List<Object?> get props => [id, username, displayName];
}
