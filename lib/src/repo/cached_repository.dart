import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

import '../model/db_model_i.dart';
import '../spec/query_transformer.dart';
import 'firebase_repository.dart';
import 'repository_addon.dart';

/// {@template cachedRepo}
/// This is a wrapper for `query` method in [FirebaseRepository].
///
/// [FirebaseRepository.query] can be used to get realtime updates from
/// Firestore with the given specification.
/// This wrapper will
///   1. Return data from Firestore cache. Or,
///   2. Return data from online db call.
///
/// And for every data returned, it will keep give realtime updates from db
/// in the background.
/// {@endtemplate}
class CachedRepository<T extends DBModelI> {
  /// Repository that is used by this wrapper.
  final FirebaseRepository<T> repository;
  final RepositoryAddon<T> _addon;

  /// {@macro cachedRepo}
  CachedRepository(this.repository)
      : _addon = RepositoryAddon(repository: repository);

  /// Same as [FirebaseRepository.query] but with caching
  Stream<Iterable<T>> query({
    required QueryTransformer<T> spec,
    required String type,
    DocumentReference? parent,
  }) {
    final cache = repository.querySingle(
      spec: spec,
      type: type,
      parent: parent,
      source: Source.cache,
    );
    return ConcatStream([
      Stream.fromFuture(cache),
      repository.query(
        spec: spec,
        type: type,
        parent: parent,
      )
    ]);
  }

  /// Same as [RepositoryAddon.transform] but with caching
  Stream<T> transform({
    required DocumentReference ref,
  }) {
    return ConcatStream([
      Stream.fromFuture(_addon.tryFetch(ref: ref, source: Source.cache))
          .handleError((_) {})
          .whereType<T>(),
      _addon.transform(ref: ref),
    ]);
  }

  /// Same as [RepositoryAddon.multiTransform] but with caching
  Stream<List<T>> multiTransform({
    required Iterable<DocumentReference> refs,
  }) {
    return ConcatStream([
      Stream.fromFuture(_addon.multiFetch(refs: refs, source: Source.cache))
          .handleError((_) {}),
      _addon.multiTransform(refs: refs),
    ]);
  }
}
