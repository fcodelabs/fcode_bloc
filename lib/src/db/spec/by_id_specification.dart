import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fcode_bloc/src/db/specification.dart';

class ByIDSpecification implements SpecificationI {
  final String _id;

  ByIDSpecification(this._id);

  @override
  Stream<List<DocumentSnapshot>> specify(CollectionReference collection) {
    return collection.document(_id).snapshots().map<List<DocumentSnapshot>>((snapshot) => [snapshot]);
  }
}
