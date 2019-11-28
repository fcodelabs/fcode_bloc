import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fcode_bloc/src/db/db_model.dart';
import 'package:fcode_bloc/src/db/reference_handler.dart';
import 'package:fcode_bloc/src/db/repo/firebase_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class ReferencesHandler<T extends DBModel> {
  final handlers = <ReferenceHandler>[];
  final _behaviorSubject = BehaviorSubject<List<T>>();
  final List<T> _items;
  final _init = Completer();

  ReferencesHandler(
      {@required FirebaseRepository<T> repository,
      List<DocumentReference> references})
      : assert(repository != null),
        assert(references != null),
        _items = List(references.length) {
    _initFill(repository, references);
  }

  @mustCallSuper
  void close() {
    _behaviorSubject.close();
    handlers.forEach((handler) => handler.close());
  }

  Future<void> _initFill(FirebaseRepository<T> repository,
      List<DocumentReference> references) async {
    for (int i = 0; i < references.length; i++) {
      final ref = references[i];
      final handler = ReferenceHandler(
        repository: repository,
        reference: ref,
      );
      _items[i] = await handler.request();
      handler.stream.listen((_) => _updateList(i));
      handlers.add(handler);
    }
    _init.complete();
  }

  Future<void> _updateList(i) async {
    _items[i] = await handlers[i].request();
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
