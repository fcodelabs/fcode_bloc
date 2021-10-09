import 'package:cloud_firestore/cloud_firestore.dart';

import 'query_transformer.dart';

/// {@template txtSpec}
/// To learn more on how to use this in an application,
/// look at [FirebaseRepository.query].
///
/// Use to query documents where the text in the given `field` starts
/// with the given `containText`.
/// {@endtemplate}
class TextStartWithQuery implements QueryTransformer {
  final String _field;
  final String _containText;

  /// {@macro txtSpec}
  TextStartWithQuery(this._field, this._containText)
      : assert(_field.isNotEmpty);

  @override
  Query transform(Query q) {
    return q
        .orderBy(_field)
        .startAt([_containText]).endAt(['$_containText\uf8ff']);
  }
}
