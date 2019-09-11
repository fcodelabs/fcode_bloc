import 'dart:async';

import 'package:fcode_bloc/bloc/bloc_listener.dart';
import 'package:fcode_bloc/bloc/bloc_provider.dart';
import 'package:fcode_bloc/bloc/ui_model.dart';
import 'package:fcode_bloc/log/log.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

abstract class BLoC<Action, S extends UIModel> {
  final _log = Log("BLoC");
  final _inHook = PublishSubject<Action>();
  final _outHook = BehaviorSubject<S>();
  final _listeners = <String, BlocListener<Action, S>>{};

  Iterable<BlocListener<Action, S>> _listenersList = [];
  S currentState;
  Action currentAction;

  BLoC() {
    currentState = initState;
    _outHook.add(currentState);

    // Every action listener
    _inHook.asyncExpand((action) {
      // Call action change in every listener
      _listenersList.forEach((listener) {
        final snapshot = BlocSnapshot<Action, S>.fromAction(action, currentAction);
        listener(snapshot);
      });
      currentAction = action;

      // Map actions to states
      return mapActionToState(action).handleError((error, [stacktrace]) {
        // If there were errors during `mapActionToState` execution,
        // handle them with listeners or print the log
        if (_listenersList.length == 0) {
          _log.e(error.toString());
          _log.e(stacktrace.toString());
        } else {
          raiseError(error, stacktrace);
        }
      });
    }).forEach((state) {
      raiseStateChange(state);
    });
  }

  /// Release the resources. This is called automatically if used with default constructor
  /// of [BlocProvider]. If [BlocProvider.value(value: foo)] is used, this function has to be
  /// called manually as `foo.dispose`.
  @mustCallSuper
  void dispose() {
    _inHook.close();
    _outHook.close();
  }

  /// Call this function to raise an error event in all the listeners.
  @protected
  void raiseError(error, [stacktrace]) {
    _listenersList.forEach((listener) {
      final snapshot = BlocSnapshot<Action, S>.fromError(error, stacktrace);
      listener(snapshot);
    });
  }

  /// Call this method to raise and StateChange event in all the listeners
  /// and to add the new state to the Bloc Stream
  @protected
  void raiseStateChange(S state) {
    // Call state change in every listener
    _listenersList.forEach((listener) {
      final snapshot = BlocSnapshot<Action, S>.fromData(state, currentState);
      listener(snapshot);
    });
    currentState = state;

    // Send new state through stream
    _outHook.add(state);
  }

  void addListener({@required String name, @required BlocListener<Action, S> listener}) {
    _listeners[name] = listener;
    _listenersList = _listeners.values;
  }

  void removeListener({@required String name}) {
    if (_listeners.containsKey(name)) {
      _listeners.remove(name);
      _listenersList = _listeners.values;
    }
  }

  Stream<S> mapActionToState(Action action);

  S get initState;

  void dispatch(Action action) {
    _inHook.sink.add(action);
  }

  Stream<S> get stream => _outHook.stream;
}
