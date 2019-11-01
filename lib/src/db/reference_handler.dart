import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fcode_bloc/src/db/db_model.dart';
import 'package:fcode_bloc/src/db/repo/firebase_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class ReferenceHandler<T extends DBModel> {
  FirebaseRepository<T> repository;
  final DocumentReference reference;
  final _listeners = ObserverList<ValueChanged<T>>();
  final _behaviorSubject = BehaviorSubject<T>();
  bool _init = false;
  T _item;
  StreamSubscription _subscription;

  ReferenceHandler({@required this.repository, @required this.reference})
      : assert(repository != null),
        assert(reference != null);

  Future<void> initialize() async {
    if (_init) {
      return;
    }
    final completer = Completer();
    _subscription?.cancel();
    _subscription = reference.snapshots().listen((snapshot) {
      _item = repository.fromSnapshot(snapshot);
      _behaviorSubject.add(_item);
      _notifyListeners();
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

  Future<T> request() async {
    await initialize();
    return _item;
  }

  Stream<T> stream() {
    initialize();
    return _behaviorSubject.stream;
  }

  void addListener(ValueChanged<T> listener) {
    assert(listener != null);
    _listeners.add(listener);
  }

  void removeListener(ValueChanged<T> listener) {
    assert(listener != null);
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    final List<ValueChanged<T>> localListeners = List<ValueChanged<T>>.from(_listeners);
    for (ValueChanged<T> listener in localListeners) {
      try {
        if (_listeners.contains(listener)) {
          listener(_item);
        }
      } catch (exception, stack) {
        FlutterError.reportError(FlutterErrorDetails(
          exception: exception,
          stack: stack,
          library: 'fcode_bloc',
          context: ErrorDescription('while notifying listeners for $runtimeType'),
          informationCollector: () sync* {
            yield DiagnosticsProperty<ReferenceHandler>(
              'The $runtimeType notifying listeners was',
              this,
              style: DiagnosticsTreeStyle.errorProperty,
            );
          },
        ));
      }
    }
  }
}
