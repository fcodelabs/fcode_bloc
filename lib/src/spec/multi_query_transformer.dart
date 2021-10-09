import 'package:cloud_firestore/cloud_firestore.dart';

import 'query_transformer.dart';

/// {@template mqt}
/// To learn more on how to use this in an application,
/// look at [FirebaseRepository.query].
///
/// This [QueryTransformer] will accept multiple [QueryTransformer] objects
/// and perform all the transformations to a given query.
/// {@endtemplate}
class MultiQueryTransformer implements QueryTransformer {
  final List<QueryTransformer> _qs;

  /// {@macro mqt}
  MultiQueryTransformer(this._qs);

  @override
  Query transform(Query q) {
    for (final qt in _qs) {
      q = qt.transform(q);
    }
    return q;
  }
}
