import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fcode_bloc/src/db/db_model.dart';
import 'package:fcode_bloc/src/db/repo/firebase_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class CollectionReferenceHandler<T extends DBModel> {
  FirebaseRepository<T> repository;
  final CollectionReference reference;
  final _behaviorSubject = BehaviorSubject<List<T>>();
  bool _init = false;
  List<T> _items;
  StreamSubscription _subscription;

  CollectionReferenceHandler({
    @required this.repository,
    @required this.reference,
  })  : assert(repository != null),
        assert(reference != null);

  Future<void> initialize() async {
    if (_init) {
      return;
    }
    final completer = Completer();
    _subscription?.cancel();
    _subscription = reference.snapshots().listen((snapshot) {
      _items = snapshot.documents.map<T>((document) {
        return repository.fromSnapshot(document);
      }).toList(growable: false);
      _behaviorSubject.add(_items);
      if (!completer.isCompleted) {
        completer.complete();
      }
    });
    await completer.future;
    _init = true;
  }

  @mustCallSuper
  void close() {
    _subscription?.cancel();
    _behaviorSubject.close();
  }

  Future<List<T>> request() async {
    await initialize();
    return _items;
  }

  Stream<List<T>> get stream {
    initialize();
    return _behaviorSubject;
  }
}
