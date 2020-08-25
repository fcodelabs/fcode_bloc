import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../specification.dart';
import 'firebase_specification.dart';

/// {@template txtSpec}
/// To know how to use [SpecificationI], look at [FirebaseRepository.query].
///
/// Use to query documents where the text in the given `field` starts
/// with the given `containText`.
/// {@endtemplate}
class TextStartWithSpecification extends FirebaseSpecificationI {
  final String _field;
  final String _containText;

  /// {@macro txtSpec}
  TextStartWithSpecification(this._field, this._containText)
      : assert(_field != null && _field.isNotEmpty),
        assert(_containText != null);

  @override
  Stream<List<DocumentSnapshot>> specify(CollectionReference collection) {
    final query = collection
        .orderBy(_field)
        .startAt([_containText]).endAt(['$_containText\uf8ff']);
    return query
        .snapshots(includeMetadataChanges: includeMetadataChanges)
        .map<List<DocumentSnapshot>>((data) => data.docs);
  }

  @override
  Future<List<DocumentSnapshot>> specifySingle(
    CollectionReference collection,
  ) async {
    final query = collection
        .orderBy(_field)
        .startAt([_containText]).endAt(['$_containText\uf8ff']);
    return (await query.get(GetOptions(
      source: source ?? Source.serverAndCache,
    )))
        .docs;
  }
}
