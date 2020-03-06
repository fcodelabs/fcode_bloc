import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _runtimeType = Timestamp.now().runtimeType;

/// Used to serialize/deserialize [Timestamp] from the [DocumentSnapshot]
class TimestampSerializer extends PrimitiveSerializer<Timestamp> {
  @override
  Iterable<Type> get types => BuiltList<Type>([
        Timestamp,
        _runtimeType,
      ]);

  @override
  String get wireName => 'Timestamp';

  @override
  Object serialize(Serializers serializers, Timestamp object,
      {FullType specifiedType = FullType.unspecified}) {
    final dateTime = object.toDate();
    if (!dateTime.isUtc) {
      throw ArgumentError.value(
          dateTime, 'dateTime', 'Must be in utc for serialization.');
    }
    return dateTime.millisecondsSinceEpoch;
  }

  @override
  Timestamp deserialize(Serializers serializers, Object serialized,
      {FullType specifiedType = FullType.unspecified}) {
    return Timestamp.fromDate(DateTime.fromMicrosecondsSinceEpoch(
      serialized as int,
      isUtc: true,
    ));
  }
}
