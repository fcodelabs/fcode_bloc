import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fcode_bloc/src/db/specification.dart';

@Deprecated("Use `ReferenceHandler` instead. Will be removed in v1.0.0")
class ByReferenceSpecification implements SpecificationI {
  final DocumentReference _documentReference;

  ByReferenceSpecification(this._documentReference);

  @override
  Stream<List<DocumentSnapshot>> specify(CollectionReference collection) {
    return _documentReference
        .snapshots()
        .map<List<DocumentSnapshot>>((data) => [data]);
  }

  @override
  Future<List<DocumentSnapshot>> specifySingle(CollectionReference collection) {
    throw ("Single Querrying not posible with Reference Specification as this class is Deprecated");
  }
}
