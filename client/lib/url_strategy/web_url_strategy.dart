// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void dummyFunctionForUrlPathStrategy() {
  usePathUrlStrategy();

  html.document.addEventListener('contextmenu', (event) {
    event.preventDefault();
  });
}
