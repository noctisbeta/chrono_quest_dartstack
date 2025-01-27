extension type JWToken._(String token) {
  JWToken.fromJwtString(String jwtString) : token = jwtString;

  String get headerBase64 => token.substring(0, token.indexOf('.'));

  String get payloadBase64 =>
      token.substring(token.indexOf('.') + 1, token.lastIndexOf('.'));

  String get signatureBase64 => token.substring(token.lastIndexOf('.') + 1);
}
