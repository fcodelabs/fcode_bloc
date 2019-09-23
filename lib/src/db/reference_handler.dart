import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fcode_bloc/src/db/db_model.dart';
import 'package:fcode_bloc/src/db/repo/firebase_repository.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class ReferenceHandler<T extends DBModel> {
  final FirebaseRepository<T> repository;
  final DocumentReference reference;
  final T model;
  final BehaviorSubject<T> _stream;
  bool _init = false;
  T _item;

  ReferenceHandler({@required this.repository, DocumentReference reference, this.model})
      : assert(reference != null || model?.ref != null),
        this.reference = reference ?? model.ref,
        _stream = BehaviorSubject.seeded(model);

  Future<void> initialize() async {
    if (_init) {
      return;
    }
    final completer = Completer();
    reference.snapshots().forEach((snapshot) {
      _item = repository.fromSnapshot(snapshot);
      if (!completer.isCompleted) {
        completer.complete();
      }
    });
    await completer.future;
    _init = true;
  }

  Future<T> request() async {
    await initialize();
    return _item;
  }

  Stream<T> get stream => _stream.stream;

  @mustCallSuper
  void dispose() {
    _stream.close();
  }
}
