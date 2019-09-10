import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fcode_bloc/db/db_model.dart';
import 'package:fcode_bloc/db/repo/firebase_repository.dart';
import 'package:flutter/material.dart';

class ReferenceHandler<T extends DBModel> {
  final FirebaseRepository<T> repository;
  final DocumentReference reference;
  bool _init = false;
  T _item;

  ReferenceHandler({@required this.repository, @required this.reference});

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
}
