import 'dart:async';

import 'package:fcode_bloc/bloc/bloc_listener.dart';
import 'package:fcode_bloc/bloc/ui_model.dart';
import 'package:fcode_bloc/log/log.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

abstract class BLoC<Action, S extends UIModel> {
  final _log = Log("BLoC");
  final _inHook = PublishSubject<Action>();
  final _outHook = BehaviorSubject<S>();
  final _subscriptions = <String, StreamSubscription<S>>{};
  final _listeners = <String, BlocListener<S>>{};
  S currentState;
  Action currentAction;

  BLoC() {
    currentState = initState;
    _inHook.asyncExpand((action) {
      currentAction = action;
      return mapActionToState(action).handleError((error, [stacktrace]) {
        _listeners.values.forEach((listener) {
          final snapshot = BlocSnapshot<S>.fromError(error, stacktrace);
          listener(snapshot);
        });
      });
    }).forEach((state) {
      currentState = state;
      _outHook.add(state);
    });
  }

  @mustCallSuper
  void dispose() {
    _inHook.close();
    _outHook.close();
    _subscriptions.values.forEach((subscription) {
      subscription.cancel();
    });
  }

  void addListener({@required String name, @required BlocListener<S> listener}) {
    removeListener(name: name);
    // ignore: cancel_subscriptions
    final subscription = _outHook.listen(
      (data) {
        final snapshot = BlocSnapshot<S>.fromData(data);
        listener(snapshot);
      },
      onError: (error, [stacktrace]) {
        final snapshot = BlocSnapshot<S>.fromError(error, stacktrace);
        listener(snapshot);
      },
      cancelOnError: false,
    );
    _listeners[name] = listener;
    _subscriptions[name] = subscription;
  }

  void removeListener({@required String name}) {
    if (_subscriptions.containsKey(name)) {
      _subscriptions[name].cancel();
    }
  }

  Stream<S> mapActionToState(Action action);

  S get initState;

  void dispatch(Action action) {
    _inHook.sink.add(action);
  }

  Stream<S> get stream => _outHook.stream;
}
