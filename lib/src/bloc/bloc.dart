import 'dart:async';

import 'package:fcode_bloc/src/bloc/bloc_listener.dart';
import 'package:fcode_bloc/src/bloc/bloc_provider.dart';
import 'package:fcode_bloc/src/bloc/ui_model.dart';
import 'package:fcode_bloc/src/log/log.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

abstract class BLoC<Action, S extends UIModel> {
  final _log = Log("BLoC");
  final _inHook = PublishSubject<Action>();
  final _outHook = BehaviorSubject<S>();
  final _listeners = <String, BlocListener<Action, S>>{};
  final _listenersList = ObserverList<BlocListener<Action, S>>();
  final _globalBlocCollector = _GlobalBlocCollector();

  S currentState;
  Action currentAction;
  StreamSubscription<S> _subscription;

  BLoC() {
    currentState = initState;
    _outHook.add(currentState);

    // Every action listener
    _subscription = _inHook.asyncExpand((action) {
      currentAction = action;

      // Map actions to states
      return mapActionToState(action).handleError((error, [stacktrace]) {
        // If there were errors during `mapActionToState` execution,
        // handle them with listeners or print the src.log
        if (_listenersList.length == 0) {
          _log.e(error.toString());
          _log.e(stacktrace.toString());
        } else {
          raiseError(error, stacktrace);
        }
      });
    }).listen((state) => raiseStateChange(state));
    _globalBlocCollector.add(this);
  }

  /// Release the resources. This is called automatically if used with default constructor
  /// of [BlocProvider]. If [BlocProvider.value(value: foo)] is used, this function has to be
  /// called manually as `foo.dispose`.
  @mustCallSuper
  void dispose() {
    _inHook.close();
    _subscription.cancel();
    _outHook.close();
    _globalBlocCollector.remove(this);
  }

  /// Call this function to raise an error event in all the listeners.
  @protected
  void raiseError(error, [stacktrace]) {
    final snapshot = BlocSnapshot<Action, S>.fromError(error, stacktrace);
    _notifyListeners(snapshot);
  }

  /// Call this method to raise and StateChange event in all the listeners
  /// and to add the new state to the Bloc Stream
  @protected
  void raiseStateChange(S state) {
    if (_outHook.isClosed) {
      return;
    }
    // Call state change in every listener
    final snapshot = BlocSnapshot<Action, S>.fromData(state, currentState);
    _notifyListeners(snapshot);
    currentState = state;

    // Send new state through stream
    _outHook.add(state);
  }

  void addListener({@required String name, @required BlocListener<Action, S> listener}) {
    removeListener(name: name);
    _listeners[name] = listener;
    _listenersList.add(listener);
  }

  void removeListener({@required String name}) {
    final listener = _listeners[name];
    if (listener != null) {
      _listeners.remove(name);
      _listenersList.remove(listener);
    }
  }

  Stream<S> mapActionToState(Action action);

  S get initState;

  void dispatch(Action action) {
    if (_inHook.isClosed) {
      return;
    }
    final snapshot = BlocSnapshot<Action, S>.fromAction(action);
    _notifyListeners(snapshot);
    _inHook.add(action);
  }

  void _notifyListeners(final BlocSnapshot<Action, S> snapshot) {
    final List<BlocListener<Action, S>> localListeners = List<BlocListener<Action, S>>.from(_listenersList);
    for (BlocListener<Action, S> listener in localListeners) {
      try {
        if (_listenersList.contains(listener)) {
          listener(snapshot);
        }
      } catch (exception, stack) {
        FlutterError.reportError(FlutterErrorDetails(
          exception: exception,
          stack: stack,
          library: 'fcode_bloc',
          context: ErrorDescription('while notifying listeners for $runtimeType'),
          informationCollector: () sync* {
            yield DiagnosticsProperty<BLoC>(
              'The $runtimeType notifying listeners was',
              this,
              style: DiagnosticsTreeStyle.errorProperty,
            );
          },
        ));
      }
    }
  }

  @protected
  void dispatchGlobally<B extends BLoC<A, dynamic>, A>(A a) {
    _globalBlocCollector.dispatchGlobally<B, A>(a);
  }

  Stream<S> get stream => _outHook.stream;
}

class _GlobalBlocCollector {
  static _GlobalBlocCollector __globalBlocCollector;
  final _collection = <String, BLoC>{};

  factory _GlobalBlocCollector() {
    if (__globalBlocCollector == null) {
      __globalBlocCollector = _GlobalBlocCollector._();
    }
    return __globalBlocCollector;
  }

  _GlobalBlocCollector._();

  void add(BLoC bloc) {
    _collection[bloc.runtimeType.toString()] = bloc;
  }

  void remove(BLoC bloc) {
    _collection.remove(bloc.runtimeType.toString());
  }

  void dispatchGlobally<B extends BLoC<A, dynamic>, A>(A a) {
    _collection[B.toString()].dispatch(a);
  }
}
