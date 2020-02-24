import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import 'db_model_i.dart';
import 'repo/firebase_repository.dart';

/// {@template refHandler}
/// Take a instance of a [FirebaseRepository] and a [DocumentReference]
/// and take the value and store in a [DBModel].
///
/// No request is sent to firestore before [ReferenceHandler.initialize] is
/// called. Then a [Stream] will update the [DBModel] on every DB change.
/// [DBModel] models can be taken as a [Stream] using [ReferenceHandler.stream]
///
/// Using [ReferenceHandler.request], the newest value in the
/// DB can be obtained. [ReferenceHandler.initialize] will be called if
/// it was not called earlier.
///
/// Make sure to [ReferenceHandler.close] the [ReferenceHandler] after
/// using it.
/// {@endtemplate}
@Deprecated("Use [FirebaseRepository.transform] instead")
class ReferenceHandler<T extends DBModelI> {
  /// [FirebaseRepository] that will be used to convert [DocumentSnapshot]s
  /// to [DBModel]s
  FirebaseRepository<T> repository;

  /// Reference to the required document in Firestore
  final DocumentReference reference;

  final _behaviorSubject = BehaviorSubject<T>();
  bool _init = false;
  T _item;
  StreamSubscription _subscription;

  /// {@macro refHandler}
  ReferenceHandler({
    @required this.repository,
    @required this.reference,
  })  : assert(repository != null),
        assert(reference != null);

  /// Start the connection with firestore and keep up a [Stream] to update
  /// the [DBModel] on each DB change. After this method been called, the
  /// [DBModel] inside will always have the latest value and can be
  /// obtained with [ReferenceHandler.request].
  ///
  /// It is safe to call multiple times, nothing will happen.
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

  /// Release all the resources that were using by the [ReferenceHandler]
  /// There will be no use of this object after this function has been
  /// called.
  ///
  /// Make sure to close it after the required task is done.
  @mustCallSuper
  Future<void> close() async {
    await _subscription?.cancel();
    await _behaviorSubject.close();
  }

  /// Request the latest value of the [reference] from Firestore.
  /// [ReferenceHandler.initialize] will be called automatically.
  Future<T> request() async {
    await initialize();
    return _item;
  }

  /// Get a [Stream] of [DBModel]s which will emmit in
  /// each time the database changes.
  /// [ReferenceHandler.initialize] will be called automatically.
  Stream<T> get stream {
    initialize();
    return _behaviorSubject;
  }
}
