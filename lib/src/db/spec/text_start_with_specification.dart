import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fcode_bloc/src/db/specification.dart';

class TextStartWithSpecification extends SpecificationI {
  final String field;
  final String containText;

  TextStartWithSpecification(this.field, this.containText)
      : assert(field != null && field.isNotEmpty),
        assert(containText != null);

  @override
  Stream<List<DocumentSnapshot>> specify(CollectionReference collection) {
    final query = collection
        .orderBy(field)
        .startAt([containText]).endAt([containText + '\uf8ff']);
    return query
        .snapshots()
        .map<List<DocumentSnapshot>>((data) => data.documents);
  }
}
