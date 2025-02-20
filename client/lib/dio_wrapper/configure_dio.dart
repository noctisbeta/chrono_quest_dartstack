export 'configure_dio_stub.dart'
    if (dart.library.io) 'configure_dio_native.dart'
    if (dart.library.js) 'configure_dio_web.dart';
