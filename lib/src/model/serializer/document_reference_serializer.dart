import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _runtimeType = Firestore.instance.document('').runtimeType;

/// Used to serialize/deserialize [DocumentReference] from [DocumentSnapshot]
class DocumentReferenceSerializer
    implements PrimitiveSerializer<DocumentReference> {
  @override
  Iterable<Type> get types => BuiltList<Type>([
        DocumentReference,
        _runtimeType,
      ]);

  @override
  String get wireName => 'DocumentReference';

  @override
  Object serialize(Serializers serializers, DocumentReference object,
      {FullType specifiedType = FullType.unspecified}) {
    return object.path;
  }

  @override
  DocumentReference deserialize(Serializers serializers, Object serialized,
      {FullType specifiedType = FullType.unspecified}) {
    return Firestore.instance.document(serialized as String);
  }
}
