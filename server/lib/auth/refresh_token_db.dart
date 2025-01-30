import 'package:common/abstractions/models.dart';
import 'package:common/exceptions/throws.dart';
import 'package:meta/meta.dart';
import 'package:server/postgres/exceptions/database_exception.dart';

@immutable
final class RefreshTokenDB extends DataModel {
  const RefreshTokenDB({
    required this.id,
    required this.userId,
    required this.token,
    required this.createdAt,
    required this.expiresAt,
    this.ipAddress,
    this.userAgent,
  });

  @Throws([DBEbadSchema])
  factory RefreshTokenDB.validatedFromMap(Map<String, dynamic> map) =>
      switch (map) {
        {
          'id': final int id,
          'user_id': final int userId,
          'token': final String token,
          'created_at': final DateTime createdAt,
          'expires_at': final DateTime expiresAt,
          'ip_address': final String? ipAddress,
          'user_agent': final String? userAgent,
        } =>
          RefreshTokenDB(
            id: id,
            userId: userId,
            token: token,
            createdAt: createdAt,
            expiresAt: expiresAt,
            ipAddress: ipAddress,
            userAgent: userAgent,
          ),
        _ => throw const DBEbadSchema('Invalid shape for RefreshTokenDB.')
      };

  final int id;
  final int userId;
  final String token;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String? ipAddress;
  final String? userAgent;

  @override
  List<Object?> get props => [
        id,
        userId,
        token,
        createdAt,
        expiresAt,
        ipAddress,
        userAgent,
      ];

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'token': token,
        'created_at': createdAt.toIso8601String(),
        'expires_at': expiresAt.toIso8601String(),
        'ip_address': ipAddress,
        'user_agent': userAgent,
      };
}
