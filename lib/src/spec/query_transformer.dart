import 'package:cloud_firestore/cloud_firestore.dart';

/// This will will transform one type of [Query] to another type of [Query].
///
/// As a example, if you got a [Query] that will return the
/// whole collection, you can transform it to a [Query] that will
/// return only 5 values, using the [Query.limit]
///
/// To learn more on how to use this in an application,
/// look at [FirebaseRepository.query].
mixin QueryTransformer<T> {

  /// Override this method to implement the way you want to transform the
  /// given [Query] [q].
  Query<T> transform(Query<T> q);
}