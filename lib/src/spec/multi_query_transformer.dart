import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/db_model_i.dart';
import 'query_transformer.dart';

/// {@template mqt}
/// To learn more on how to use this in an application,
/// look at [FirebaseRepository.query].
///
/// This [QueryTransformer] will accept multiple [QueryTransformer] objects
/// and perform all the transformations to a given query.
/// {@endtemplate}
class MultiQueryTransformer<T extends DBModelI> implements QueryTransformer<T> {
  final List<QueryTransformer<T>> _qs;

  /// {@macro mqt}
  MultiQueryTransformer(this._qs);

  @override
  Query<T> transform(Query<T> q) {
    for (final qt in _qs) {
      q = qt.transform(q);
    }
    return q;
  }
}
