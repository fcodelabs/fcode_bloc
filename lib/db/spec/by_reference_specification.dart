import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fcode_bloc/db/specification.dart';

class ByReferenceSpecification implements SpecificationI {
  final DocumentReference _documentReference;

  ByReferenceSpecification(this._documentReference);

  @override
  Stream<List<DocumentSnapshot>> specify(CollectionReference collection) {
    return _documentReference.snapshots().map<List<DocumentSnapshot>>((data) => [data]);
  }
}
