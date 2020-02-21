import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fcode_bloc/src/db/specification.dart';

@Deprecated("Create a DocumentReference with the `id` and use [FirebaseRepository.transform] instead of querying. Use fetch for Futures.")
class ByIDSpecification implements SpecificationI {
  final String _id;

  ByIDSpecification(this._id) : assert(_id != null && _id.isNotEmpty);

  @override
  Stream<List<DocumentSnapshot>> specify(CollectionReference collection) {
    return collection
        .document(_id)
        .snapshots()
        .map<List<DocumentSnapshot>>((snapshot) => [snapshot]);
  }

  @override
  Future<List<DocumentSnapshot>> specifySingle(
    CollectionReference collection,
  ) async {
    return [await collection.document(_id).get()];
  }
}
