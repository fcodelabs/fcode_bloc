import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import '../../fcode_bloc.dart';

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
  Stream<List<T>> query({
    @required SpecificationI specification,
    String type,
    DocumentReference parent,
  }) {
    final spec = specification as FirebaseSpecificationI;
    spec.source = Source.cache;
    final cache = repository.querySingle(
      specification: spec,
      type: type,
      parent: parent,
    );
    spec.source = Source.serverAndCache;
    return ConcatStream([
      Stream.fromFuture(cache),
      repository.query(
        specification: spec,
        type: type,
        parent: parent,
      )
    ]);
  }

  /// Same as [RepositoryAddon.transform] but with caching
  Stream<T> transform({
    @required DocumentReference ref,
  }) {
    return ConcatStream([
      Stream.fromFuture(_addon.fetch(ref: ref, source: Source.cache))
          .handleError(() {}),
      _addon.transform(ref: ref),
    ]);
  }

  /// Same as [RepositoryAddon.multiTransform] but with caching
  Stream<List<T>> multiTransform({
    @required Iterable<DocumentReference> refs,
  }) {
    return ConcatStream([
      Stream.fromFuture(_addon.multiFetch(refs: refs, source: Source.cache))
          .handleError(() {}),
      _addon.multiTransform(refs: refs),
    ]);
  }
}
