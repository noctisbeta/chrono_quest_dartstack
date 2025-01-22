import 'package:common/exceptions/throws.dart';
import 'package:common/requests/request.dart';
import 'package:meta/meta.dart';
import 'package:server/postgres/exceptions/database_exception.dart';

@immutable
final class UserDB extends Model {
  const UserDB({
    required this.id,
    required this.displayName,
    required this.username,
    required this.hashedPassword,
    required this.salt,
    required this.createdAt,
    required this.updatedAt,
  });

  @Throws([DBEbadSchema])
  factory UserDB.validatedFromMap(Map<String, dynamic> map) => switch (map) {
        {
          'id': final int id,
          'display_name': final String? displayName,
          'username': final String username,
          'hashed_password': final String hashedPassword,
          'salt': final String salt,
          'created_at': final DateTime createdAt,
          'updated_at': final DateTime updatedAt,
        } =>
          UserDB(
            id: id,
            displayName: displayName,
            username: username,
            hashedPassword: hashedPassword,
            salt: salt,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
        _ => throw const DBEbadSchema('Invalid shape for UserDB.')
      };

  final int id;
  final String? displayName;
  final String username;
  final String hashedPassword;
  final String salt;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props =>
      [id, displayName, username, hashedPassword, salt, createdAt, updatedAt];

  @override
  bool get stringify => true;

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'display_name': displayName,
        'username': username,
        'hashed_password': hashedPassword,
        'salt': salt,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
