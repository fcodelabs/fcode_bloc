import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../fcode_bloc.dart';
import '../specification.dart';

/// {@template idRef}
/// To know how to use [SpecificationI], look at [FirebaseRepository.query].
///
/// Provide a `id` to create a [SpecificationI] that can be used to query
/// documents by their IDs from the Firestore.
/// {@endtemplate}
@Deprecated("Create a DocumentReference with the `id` and "
    "use [FirebaseRepository.transform] instead of querying. "
    "Use [FirebaseRepository.fetch] for Futures.")
class ByIDSpecification implements SpecificationI {
  final String _id;

  /// {@macro idRef}
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
