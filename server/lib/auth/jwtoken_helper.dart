import 'dart:convert';

import 'package:common/auth/tokens/jwtoken.dart';
import 'package:crypto/crypto.dart';
import 'package:dotenv/dotenv.dart';

class JWTokenHelper {
  JWTokenHelper._();

  static JWToken getFromAuthorizationHeader(String authorizationHeader) {
    final List<String> parts = authorizationHeader.split(' ');

    if (parts.length != 2 || parts.first != 'Bearer') {
      throw Exception('Invalid authorization header');
    }

    return JWToken.fromJwtString(parts.last);
  }

  static JWToken createWith({required int userID}) {
    final String header = jsonEncode({'typ': 'JWT', 'alg': 'HS256'});
    final String headerBase64 =
        base64Url.encode(utf8.encode(header)).replaceAll('=', '');

    final String payload = jsonEncode({
      'user_id': userID,
      'exp': DateTime.now()
              .add(const Duration(seconds: 30))
              .millisecondsSinceEpoch ~/
          1000,
    });
    final String payloadBase64 =
        base64Url.encode(utf8.encode(payload)).replaceAll('=', '');

    final String signature = _generateSignature(headerBase64, payloadBase64);

    return JWToken.fromJwtString('$headerBase64.$payloadBase64.$signature');
  }

  static bool verifyToken(JWToken token) {
    final String signature = _generateSignature(
      token.headerBase64,
      token.payloadBase64,
    );

    if (signature != token.signatureBase64) {
      return false;
    }

    final Map<String, dynamic> payload =
        jsonDecode(utf8.decode(base64Url.decode(token.payloadBase64)));
    final int expiryTimestamp = payload['exp'];
    final DateTime expiryDate =
        DateTime.fromMillisecondsSinceEpoch(expiryTimestamp * 1000);

    return DateTime.now().isBefore(expiryDate);
  }

  static String _generateSignature(String headerBase64, String payloadBase64) {
    final env = DotEnv(includePlatformEnvironment: true)..load();

    final String? secret = env['JWT_SECRET'];

    if (secret == null) {
      throw Exception('JWT_SECRET not found in .env');
    }

    final hmac = Hmac(sha256, utf8.encode(secret));

    final Digest digest =
        hmac.convert(utf8.encode('$headerBase64.$payloadBase64'));

    return base64Url.encode(digest.bytes).replaceAll('=', '');
  }
}
