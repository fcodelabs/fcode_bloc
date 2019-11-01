// Copyright 2019 The Fcode Labs Authors. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:bloc/bloc.dart' as _b;
import 'package:fcode_bloc/src/bloc/bloc_callback.dart';
import 'package:fcode_bloc/src/bloc/ui_model.dart';
import 'package:fcode_bloc/src/log/log.dart';
import 'package:flutter/foundation.dart';

abstract class BLoC<Action, State extends UIModel> extends _b.Bloc<Action, State> {
  final _log = Log("BLoC");
  final _listeners = ObserverList<BlocCallback<Action, State>>();
  final _listenersMap = <String, BlocCallback<Action, State>>{};
  bool _disposed = false;

  void addListener({@required String name, @required BlocCallback<Action, State> listener}) {
    assert(name != null && name.isNotEmpty);
    assert(listener != null);
    removeListener(name: name);
    _listenersMap[name] = listener;
    _listeners.add(listener);
  }

  void removeListener({@required String name}) {
    assert(name != null && name.isNotEmpty);
    final listener = _listenersMap[name];
    if (listener != null) {
      _listenersMap.remove(name);
      _listeners.remove(listener);
    }
    _listeners.remove(listener);
  }

  @override
  Stream<State> mapEventToState(Action action);

  @override
  @deprecated
  void onError(Object error, StackTrace stacktrace) {
    if (_disposed) {
      _log.e(error.toString());
      _log.e(stacktrace?.toString() ?? "");
      return;
    }
    final snapshot = BlocSnapshot<Action, State>.fromError(error, stacktrace);
    _notifyListeners(snapshot);
  }

  @override
  @deprecated
  void onEvent(Action action) {
    if (_disposed) {
      return;
    }
    final snapshot = BlocSnapshot<Action, State>.fromAction(action);
    _notifyListeners(snapshot);
  }

  @override
  @deprecated
  void onTransition(_b.Transition<Action, State> transition) {
    if (_disposed) {
      return;
    }
    final snapshot = BlocSnapshot<Action, State>.fromData(
      transition.nextState,
      transition.currentState,
      transition.event,
    );
    _notifyListeners(snapshot);
  }

  void _notifyListeners(final BlocSnapshot<Action, State> snapshot) {
    final List<BlocCallback<Action, State>> localListeners = List<BlocCallback<Action, State>>.from(_listeners);
    for (BlocCallback<Action, State> listener in localListeners) {
      try {
        if (_listeners.contains(listener)) {
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

  @override
  void close() {
    _disposed = true;
    state.close();
    super.close();
  }
}
