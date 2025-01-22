import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

final class Hasher {
  ({String hashedPassword, String salt}) hashPassword(String password) {
    final String salt = _generateSalt();
    final String hashedPassword = _hash(password, salt);

    return (hashedPassword: hashedPassword, salt: salt);
  }

  bool verifyPassword(String password, String hashedPassword, String salt) {
    final String newHash = _hash(password, salt);

    return newHash == hashedPassword;
  }

  String _hash(String password, String salt) {
    final Uint8List bytes = utf8.encode(password);
    final Uint8List saltBytes = utf8.encode(salt);

    final hmac = Hmac(sha256, saltBytes);

    final Digest digest = hmac.convert(bytes);
    return digest.toString();
  }

  String _generateSalt([int length = 16]) {
    final random = Random.secure();

    final salt = List<int>.generate(length, (_) => random.nextInt(256));

    return String.fromCharCodes(salt);
  }
}
