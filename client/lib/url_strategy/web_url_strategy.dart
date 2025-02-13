import 'dart:js_interop';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:web/web.dart' as web;

void dummyFunctionForUrlPathStrategy() {
  usePathUrlStrategy();

  // Get the document object from the web package
  final web.Document document = web.window.document;

  // Define the event handler type explicitly
  void handler(web.Event event) {
    event.preventDefault();
  }

  // Add the event listener with the correct type
  document.addEventListener('contextmenu', handler.toJS);
}
