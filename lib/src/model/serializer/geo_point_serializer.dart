import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _runtimeType = GeoPoint(0, 0).runtimeType;

/// Used to serialize/deserialize [GeoPoint] from [DocumentSnapshot]
class GeoPointSerializer extends PrimitiveSerializer<GeoPoint> {
  @override
  Iterable<Type> get types => BuiltList<Type>([
        GeoPoint,
        _runtimeType,
      ]);

  @override
  String get wireName => 'GeoPoint';

  @override
  Object serialize(Serializers serializers, GeoPoint object,
      {FullType specifiedType = FullType.unspecified}) {
    return '${object.latitude}:${object.longitude}';
  }

  @override
  GeoPoint deserialize(Serializers serializers, Object serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final coordinates = (serialized as String).split(":");
    return GeoPoint(
      double.parse(coordinates[0]),
      double.parse(coordinates[1]),
    );
  }
}
