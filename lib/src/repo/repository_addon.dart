import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

import '../model/db_model_i.dart';
import 'firebase_repository.dart';

/// {@template repo}
/// Provide additional functionality to a [FirebaseRepository]
/// {@endtemplate}
class RepositoryAddon<T extends DBModelI> {
  final FirebaseRepository<T> _repo;

  /// {@macro repo}
  RepositoryAddon({required FirebaseRepository<T> repository})
      : _repo = repository;

  /// Transform the given [ref] to a [Stream] of [T]s.
  /// The [Stream] will emmit new values each time there is a change
  /// in the DB.
  Stream<T> transform({
    required DocumentReference ref,
  }) {
    return ref
        .snapshots()
        .map<T?>(_repo.fromSnapshot)
        .where((item) => item != null)
        .whereType<T>();
  }

  /// Same as [RepositoryAddon.transform] but will return a [Future] with
  /// latest value in the DB using the given [ref].
  /// If the given [ref] is not found, this will return [null] without
  /// throwing any exception.
  Future<T?> tryFetch({
    required DocumentReference ref,
    Source source = Source.serverAndCache,
  }) async {
    try {
      return await fetch(ref: ref, source: source);
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      return null;
    }
  }

  /// Same as [RepositoryAddon.transform] but will return a [Future] with
  /// latest value in the DB using the given [ref].
  /// If the given [ref] is not found, this will throw an exception.
  Future<T> fetch({
    required DocumentReference ref,
    Source source = Source.serverAndCache,
  }) async {
    final snapshot = await ref.get(GetOptions(source: source));
    return _repo.fromSnapshot(snapshot)!;
  }

  /// Transform the given [refs] to a [List] of [T]s.
  /// The [Stream] will emmit new values each time there is a change
  /// in the DB.
  Stream<List<T>> multiTransform({
    required Iterable<DocumentReference> refs,
  }) {
    return CombineLatestStream.list(refs.map<Stream<T>>(
      (ref) => transform(ref: ref),
    ));
  }

  /// Same as [RepositoryAddon.multiTransform] but will return a [Future] with
  /// latest values in the DB using the given [refs].
  Future<List<T>> multiFetch({
    required Iterable<DocumentReference> refs,
    Source source = Source.serverAndCache,
  }) async {
    final futures = refs.map((ref) async => await tryFetch(
          ref: ref,
          source: source,
        ));
    return (await Future.wait(futures))
        .where((i) => i != null)
        .whereType<T>()
        .toList(growable: false);
  }

  /// Update the array in the [field] of the Document [ref] with the given
  /// [List] of [values].
  ///
  /// If [add] is true, the [values] will be added to [ref] and removed
  /// otherwise.
  static Future<void> arrayUpdate({
    required DocumentReference ref,
    required String field,
    required List<dynamic> values,
    bool add = true,
  }) async {
    assert(field.isNotEmpty);
    assert(values.isNotEmpty);
    if (add) {
      return await ref.update({
        field: FieldValue.arrayUnion(values),
      });
    } else {
      return await ref.update({
        field: FieldValue.arrayRemove(values),
      });
    }
  }

  /// Same as [Firestore.instance.runTransaction]
  static Future<T> runTransaction<T>({
    required TransactionHandler<T> transactionHandler,
    Duration? timeout,
  }) async {
    return await FirebaseFirestore.instance.runTransaction(
      transactionHandler,
      timeout: timeout ?? const Duration(seconds: 30),
    );
  }

  /// Same as [Firestore.instance.batch]
  static WriteBatch getBatch() {
    return FirebaseFirestore.instance.batch();
  }
}
