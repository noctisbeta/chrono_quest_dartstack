import 'package:common/abstractions/map_serializable.dart';
import 'package:equatable/equatable.dart';

abstract base class DataModel extends Equatable implements MapSerializable {
  const DataModel();

  @override
  bool get stringify => true;
}

typedef Response = DataModel;

typedef Request = DataModel;
