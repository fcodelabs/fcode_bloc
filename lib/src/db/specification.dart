import 'package:cloud_firestore/cloud_firestore.dart';

import '../../fcode_bloc.dart';

/// To know how to use [SpecificationI], look at [FirebaseRepository.query].
///
/// Can be used to query a [List] of specific values from the Firestore.
/// Implement [SpecificationI.specify] and [SpecificationI.specifySingle]
/// according to the need of the query.
abstract class SpecificationI {
  /// Used by [FirebaseRepository.query] to get a [Stream] of
  /// [List] of [DocumentReference]s according to the specified rule
  /// in the implementation.
  Stream<List<DocumentSnapshot>> specify(CollectionReference collection);

  /// Same as [SpecificationI.specify] but this will return a [Future]
  /// so that it can be used by [FirebaseRepository.querySingle]
  Future<List<DocumentSnapshot>> specifySingle(CollectionReference collection);
}
