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
  final _listeners = ObserverList<ValueChanged<List<T>>>();
  final _behaviorSubject = BehaviorSubject<List<T>>();
  bool _init = false;
  List<T> _items;
  StreamSubscription _subscription;

  CollectionReferenceHandler({@required this.repository, @required this.reference});

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
      _notifyListeners();
      if (!completer.isCompleted) {
        completer.complete();
      }
    });
    await completer.future;
    _init = true;
  }

  @mustCallSuper
  void dispose() {
    _subscription?.cancel();
    _behaviorSubject.close();
  }

  Future<List<T>> request() async {
    await initialize();
    return _items;
  }

  Stream<List<T>> stream() {
    initialize();
    return _behaviorSubject.stream;
  }

  void addListener(ValueChanged<List<T>> listener) {
    _listeners.add(listener);
  }

  void removeListener(ValueChanged<List<T>> listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    final List<ValueChanged<List<T>>> localListeners = List<ValueChanged<List<T>>>.from(_listeners);
    for (ValueChanged<List<T>> listener in localListeners) {
      try {
        if (_listeners.contains(listener)) {
          listener(_items);
        }
      } catch (exception, stack) {
        FlutterError.reportError(FlutterErrorDetails(
          exception: exception,
          stack: stack,
          library: 'fcode_bloc',
          context: ErrorDescription('while notifying listeners for $runtimeType'),
          informationCollector: () sync* {
            yield DiagnosticsProperty<CollectionReferenceHandler>(
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