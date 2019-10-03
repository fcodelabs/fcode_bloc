import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fcode_bloc/src/db/db_model.dart';
import 'package:fcode_bloc/src/db/reference_handler.dart';
import 'package:fcode_bloc/src/db/repo/firebase_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ReferencesHandler<T extends DBModel> {
  final handlers = <ReferenceHandler>[];
  final _listeners = ObserverList<ValueChanged<List<T>>>();
  final List<T> _items;
  final _init = Completer();

  ReferencesHandler({@required FirebaseRepository<T> repository, List<DocumentReference> references})
      : _items = List(references.length) {
    _initFill(repository, references);
  }

  @mustCallSuper
  void dispose() {
    handlers.forEach((handler) => handler.dispose());
  }

  Future<void> _initFill(FirebaseRepository<T> repository, List<DocumentReference> references) async {
    for (int i = 0; i < references.length; i++) {
      final ref = references[i];
      final handler = ReferenceHandler(
        repository: repository,
        reference: ref,
      );
      _items.add(await handler.request());
      handler.addListener((_) => _updateList(i));
      handlers.add(handler);
    }
    _init.complete();
  }

  Future<void> _updateList(i) async {
    _items[i] = await handlers[i].request();
    _notifyListeners();
  }

  Future<List<T>> request() async {
    await _init.future;
    return _items;
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
            yield DiagnosticsProperty<ReferencesHandler>(
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
