import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fcode_bloc/src/db/db_model.dart';
import 'package:fcode_bloc/src/db/repo/firebase_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

@Deprecated("Use [FirebaseRepository.transform] instead")
class ReferenceHandler<T extends DBModel> {
  FirebaseRepository<T> repository;
  final DocumentReference reference;
  final _behaviorSubject = BehaviorSubject<T>();
  bool _init = false;
  T _item;
  StreamSubscription _subscription;

  ReferenceHandler({
    @required this.repository,
    @required this.reference,
  })  : assert(repository != null),
        assert(reference != null);

  Future<void> initialize() async {
    if (_init) {
      return;
    }
    final completer = Completer();
    await _subscription?.cancel();
    _subscription = reference.snapshots().listen((snapshot) {
      _item = repository.fromSnapshot(snapshot);
      _behaviorSubject.add(_item);
      if (!completer.isCompleted) {
        completer.complete();
      }
    });
    await completer.future;
    _init = true;
  }

  @mustCallSuper
  Future<void> close() async {
    await _subscription?.cancel();
    await _behaviorSubject.close();
  }

  Future<T> request() async {
    await initialize();
    return _item;
  }

  Stream<T> get stream {
    initialize();
    return _behaviorSubject;
  }
}
