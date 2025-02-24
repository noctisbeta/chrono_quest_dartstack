import 'package:common/abstractions/models.dart';
import 'package:meta/meta.dart';

@immutable
final class GetReferenceDateRequest extends RequestDTO {
  const GetReferenceDateRequest();

  factory GetReferenceDateRequest.validatedFromMap(Map<String, dynamic> _) =>
      const GetReferenceDateRequest();

  @override
  Map<String, dynamic> toMap() => {};

  @override
  List<Object?> get props => [];

  @override
  GetReferenceDateRequest copyWith() => const GetReferenceDateRequest();
}
