import 'dart:async';

import 'package:fcode_mvp/bloc/bloc_listener.dart';
import 'package:fcode_mvp/bloc/hook.dart';
import 'package:fcode_mvp/bloc/ui_model.dart';
import 'package:fcode_mvp/log/log.dart';
import 'package:flutter/material.dart';

abstract class BLoC<Action, S extends UIModel> {
  final _log = Log("BLoC");
  final _inHook = Hook<Action>();
  final _outHook = Hook<S>();
  final _subscriptions = <String, StreamSubscription<S>>{};
  final _listeners = <String, BlocListener<S>>{};
  S currentState;
  Action currentAction;

  BLoC() {
    currentState = initState;
    _inHook.stream.asyncExpand((action) {
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

  void dispose() {
    _inHook.dispose();
    _outHook.dispose();
    _subscriptions.values.forEach((subscription) {
      subscription.cancel();
    });
  }

  void addListener({@required String name, @required BlocListener<S> listener}) {
    removeListener(name: name);
    // ignore: cancel_subscriptions
    final subscription = _outHook.stream.listen((data) {
      final snapshot = BlocSnapshot<S>.fromData(data);
      listener(snapshot);
    },
      onError: (error, [stacktrace]) {
        final snapshot = BlocSnapshot<S>.fromError(error, stacktrace);
        listener(snapshot);
      },
      cancelOnError: false,
    );
    Future.microtask(() {
      final snapshot = BlocSnapshot<S>.fromData(currentState);
      listener(snapshot);
    });
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
    _inHook.add(action);
  }

  Stream<S> get stream => _outHook.stream;
}
