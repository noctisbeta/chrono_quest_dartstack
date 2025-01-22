import 'package:common/abstractions/map_serializable.dart';
import 'package:equatable/equatable.dart';

abstract base class Request extends Equatable implements MapSerializable {
  const Request();

  @override
  bool get stringify => true;
}

typedef Response = Request;

typedef Model = Request;
