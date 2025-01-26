import 'dart:convert';

import 'package:crypto/crypto.dart';

extension type JWToken._(String token) {
  factory JWToken.createWith({required int userID}) {
    final String header = jsonEncode({'typ': 'JWT', 'alg': 'HS256'});
    final String headerBase64 = base64Url.encode(utf8.encode(header));

    final String payload = jsonEncode({'username': userID});
    final String payloadBase64 = base64Url.encode(utf8.encode(payload));

    final String signature = _generateSignature(headerBase64, payloadBase64);

    return JWToken._('$headerBase64.$payloadBase64.$signature');
  }

  String get headerBase64 => token.substring(0, token.indexOf('.'));

  String get payloadBase64 =>
      token.substring(token.indexOf('.') + 1, token.lastIndexOf('.'));

  String get signatureBase64 => token.substring(token.lastIndexOf('.') + 1);

  bool verifyToken() {
    final String signature = _generateSignature(headerBase64, payloadBase64);

    return signature == signatureBase64;
  }

  static String _generateSignature(String headerBase64, String payloadBase64) {
    final hmac = Hmac(sha256, utf8.encode('secret'));

    final Digest digest =
        hmac.convert(utf8.encode('$headerBase64.$payloadBase64'));

    return base64Url.encode(digest.bytes);
  }
}
