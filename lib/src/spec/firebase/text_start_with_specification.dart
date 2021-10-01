import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../model/db_model_i.dart';
import '../specification.dart';
import 'firebase_specification.dart';

/// {@template txtSpec}
/// To know how to use [SpecificationI], look at [FirebaseRepository.query].
///
/// Use to query documents where the text in the given `field` starts
/// with the given `containText`.
/// {@endtemplate}
class TextStartWithSpecification<T extends DBModelI>
    extends FirebaseSpecificationI<T> {
  final String _field;
  final String _containText;

  /// {@macro txtSpec}
  TextStartWithSpecification(this._field, this._containText)
      : assert(_field.isNotEmpty);

  @override
  Stream<Iterable<T>> specify(Query<T> collection) {
    final query = collection
        .orderBy(_field)
        .startAt([_containText]).endAt(['$_containText\uf8ff']);
    return query
        .snapshots(includeMetadataChanges: includeMetadataChanges)
        .map((data) => data.docs.map((e) => e.data()));
  }

  @override
  Future<Iterable<T>> specifySingle(
    Query<T> collection,
  ) async {
    final query = collection
        .orderBy(_field)
        .startAt([_containText]).endAt(['$_containText\uf8ff']);
    return (await query.get(GetOptions(source: source)))
        .docs
        .map((e) => e.data());
  }
}
