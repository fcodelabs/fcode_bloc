import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fcode_bloc/db/specification.dart';

class ByReferencesSpecification implements SpecificationI {
  final List<DocumentReference> _documentReferences;

  ByReferencesSpecification(this._documentReferences);

  @override
  Stream<List<DocumentSnapshot>> specify(CollectionReference collection) async* {
    final snapshots = <DocumentSnapshot>[];
    for (final ref in _documentReferences) {
      snapshots.add(await ref.get());
    }
    yield snapshots;
  }
}
