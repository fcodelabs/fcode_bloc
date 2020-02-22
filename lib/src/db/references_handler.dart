import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import 'db_model.dart';
import 'reference_handler.dart';
import 'repo/firebase_repository.dart';

@Deprecated("Use [FirebaseRepository.multiTransform] instead")
class ReferencesHandler<T extends DBModel> {
  final _handlers = <ReferenceHandler>[];
  final _behaviorSubject = BehaviorSubject<List<T>>();
  final _subscriptions = <StreamSubscription>[];
  final List<T> _items;
  final _init = Completer();

  ReferencesHandler({
    @required FirebaseRepository<T> repository,
    List<DocumentReference> references,
  })  : assert(repository != null),
        assert(references != null),
        _items = List(references.length) {
    _initFill(repository, references);
  }

  @mustCallSuper
  Future<void> close() async {
    for (final h in _handlers) {
      await h.close();
    }
    for (final s in _subscriptions) {
      await s.cancel();
    }
    await _behaviorSubject.close();
  }

  Future<void> _initFill(FirebaseRepository<T> repository,
      List<DocumentReference> references) async {
    for (var i = 0; i < references.length; i++) {
      final ref = references[i];
      final handler = ReferenceHandler(
        repository: repository,
        reference: ref,
      );
      _items[i] = await handler.request();
      _subscriptions.add(handler.stream.listen((_) => _updateList(i)));
      _handlers.add(handler);
    }
    _init.complete();
  }

  Future<void> _updateList(i) async {
    _items[i] = await _handlers[i].request();
    _behaviorSubject.add(_items);
  }

  Future<List<T>> request() async {
    await _init.future;
    return _items;
  }

  Stream<List<T>> get stream {
    return _behaviorSubject;
  }
}
