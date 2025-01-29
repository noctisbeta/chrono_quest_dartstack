import 'package:common/abstractions/models.dart';
import 'package:common/exceptions/bad_map_shape_exception.dart';
import 'package:common/exceptions/throws.dart';
import 'package:meta/meta.dart';

@immutable
final class User extends DataModel {
  const User({
    required this.id,
    required this.username,
  });

  @Throws([BadMapShapeException])
  factory User.validatedFromMap(Map<String, dynamic> map) => switch (map) {
        {
          'id': final int id,
          'username': final String username,
        } =>
          User(
            id: id,
            username: username,
          ),
        _ => throw const BadMapShapeException(
            'Invalid map format for User',
          ),
      };

  final int id;
  final String username;

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'username': username,
      };

  @override
  List<Object?> get props => [id, username];
}
