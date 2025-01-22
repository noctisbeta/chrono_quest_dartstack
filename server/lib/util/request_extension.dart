import 'dart:io';

import 'package:common/exceptions/request_exception.dart';
import 'package:dart_frog/dart_frog.dart';

extension RequestExtension on Request {
  /// Throws [BadRequestContentTypeException] if the request's content type
  /// is not [mime].
  void assertContentType(String mime) =>
      headers[HttpHeaders.contentTypeHeader]?.contains(mime) ?? false
          ? true
          : throw const BadRequestContentTypeException('Invalid content type');
}
