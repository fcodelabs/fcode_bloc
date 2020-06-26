import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import '../model/db_model_i.dart';
import 'firebase_repository.dart';

/// {@template repo}
/// Provide additional functionality to a [FirebaseRepository]
/// {@endtemplate}
class RepositoryAddon<T extends DBModelI> {
  final FirebaseRepository<T> _repo;

  /// {@macro repo}
  RepositoryAddon({@required FirebaseRepository<T> repository})
      : assert(repository != null),
        _repo = repository;

  /// Transform the given [ref] to a [Stream] of [T]s.
  /// The [Stream] will emmit new values each time there is a change
  /// in the DB.
  Stream<T> transform({
    @required DocumentReference ref,
  }) {
    return ref.snapshots().map<T>(_repo.fromSnapshot);
  }

  /// Same as [RepositoryAddon.transform] but will return a [Future] with
  /// latest value in the DB using the given [ref].
  Future<T> fetch({
    @required DocumentReference ref,
    Source source = Source.serverAndCache,
    bool exception = true,
  }) async {
    if (exception) {
      return _fetch(ref: ref, source: source);
    }
    try {
      return _fetch(ref: ref, source: source);
    } on Exception {
      return null;
    }
  }

  Future<T> _fetch({
    @required DocumentReference ref,
    @required Source source,
  }) async {
    final snapshot = await ref.get(source: source);
    return _repo.fromSnapshot(snapshot);
  }

  /// Transform the given [refs] to a [List] of [T]s.
  /// The [Stream] will emmit new values each time there is a change
  /// in the DB.
  Stream<List<T>> multiTransform({
    @required Iterable<DocumentReference> refs,
  }) {
    return CombineLatestStream.list(refs.map<Stream<T>>(
      (ref) => transform(ref: ref),
    ));
  }

  /// Same as [RepositoryAddon.multiTransform] but will return a [Future] with
  /// latest values in the DB using the given [refs].
  Future<List<T>> multiFetch({
    @required Iterable<DocumentReference> refs,
    Source source = Source.serverAndCache,
  }) {
    final futures = refs.map((ref) => fetch(
          ref: ref,
          source: source,
          exception: false,
        ));
    return Future.wait(futures);
  }

  /// Update the array in the [field] of the Document [ref] with the given
  /// [List] of [values].
  ///
  /// If [add] is true, the [values] will be added to [ref] and removed
  /// otherwise.
  static Future<void> arrayUpdate({
    @required DocumentReference ref,
    @required String field,
    @required List<dynamic> values,
    bool add = true,
  }) async {
    assert(ref != null);
    assert(field?.isNotEmpty ?? false);
    assert(values?.isNotEmpty ?? false);
    if (add) {
      return await ref.updateData({
        field: FieldValue.arrayUnion(values),
      });
    } else {
      return await ref.updateData({
        field: FieldValue.arrayRemove(values),
      });
    }
  }

  /// Same as [Firestore.instance.runTransaction]
  static Future<Map<String, dynamic>> runTransaction({
    @required TransactionHandler transactionHandler,
    Duration timeout,
  }) async {
    return await Firestore.instance.runTransaction(
      transactionHandler,
      timeout: timeout,
    );
  }

  /// Same as [Firestore.instance.batch]
  static WriteBatch getBatch() {
    return Firestore.instance.batch();
  }
}
