import 'package:common/abstractions/map_serializable.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract base class DataModelDTO extends Equatable implements MapSerializable {
  const DataModelDTO();

  @override
  bool get stringify => true;
}

typedef ResponseDTO = DataModelDTO;

typedef RequestDTO = DataModelDTO;
