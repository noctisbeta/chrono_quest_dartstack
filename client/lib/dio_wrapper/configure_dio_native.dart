import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

void configureDioAdapter(Dio dio) {
  (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
    final client = HttpClient()..badCertificateCallback = (_, _, _) => true;
    return client;
  };
}
