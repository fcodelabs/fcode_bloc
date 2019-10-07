// Copyright 2019 The Fcode Labs Authors. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:fcode_bloc/fcode_bloc.dart';
import 'package:fcode_bloc/src/bloc/bloc_listener.dart';
import 'package:fcode_bloc/src/bloc/bloc_provider.dart';
import 'package:fcode_bloc/src/bloc/ui_model.dart';
import 'package:fcode_bloc/src/log/log.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

/// Takes a [Stream] of [Action]s and transform it to a [Stream] of States ([S]s).
/// `State` has to be child of [UIModel].
///
/// For every [Action], [BLoC] will generate a [Stream] of `State`s. Override [mapActionToState] method
/// to convert [Action]s to a [Stream] of `State`s. Initial `State` of the [BLoC] has to given
/// by overriding [initState].
///
/// ```dart
/// class SomeAction {
///   static const String INCREMENT = 'Increment';
///
///   final String action;
///   SomeAction(this.action);
/// }
///
/// // ...
///
/// class SomeModel extends UIModel {
///   int count;
///
///   SomeModel({this.count});
///
///   @override
///   SomeModel clone() {
///     return SomeModel(count: count);
///   }
/// }
///
/// // ...
///
/// class SomeBloc extends BLoC<SomeAction, SomeModel> {
///   @override
///   SomeModel get initState => SomeModel(count: 0);
///
///   @override
///   Stream<SomeModel> mapActionToState(SomeAction action) async* {
///     switch(action.action) {
///       case SomeAction.INCREMENT:
///         final state = currentState.clone();
///         state.count += 1;
///         yield state;
///         break;
///     }
///   }
/// }
/// ```
///
/// [Action]s can be added to the [BLoC] by calling [dispatch] method.
///
/// Make sure to call [dispose] after using the [BLoC] to release the resources.
///
/// ```dart
/// final bloc = SomeBloc();
/// bloc.dispatch(SomeAction(SomeAction.INCREMENT));
///
/// // ...
///
/// bloc.dispose();
/// ```
///
/// Typically [BLoC] is used with [BlocProvider]s so that the [BLoC] can be accessed by
/// any [Widget] in the tree. See documentation of [BlocProvider] for an example of the usage.
///
/// [initState] must be override to provide the initial State ([S]) for the [BLoC].
/// [mapActionToState] must be override to convert the dispatched actions to a [Stream] of `State`s.
///
/// Updated [Stream] can be accessed via [stream] property. Without directly using [stream] property
/// it is better to use [BlocBuilder]s or [BlocListener]s to access `State` changes.
///
/// See also:
///
///  * [BlocProvider], which can be used to provide [BLoC]s to the [Widget] tree.
///  * [MultiBlocProvider], which can be used to provide multiple [BLoC]s down the [Widget] tree.
///  * [BlocBuilder], which can be used as a [Widget] that will be rebuilt itself on
///    `State` changes in the [BLoC].
///  * [BlocListener], which will trigger on `State` change, [Action] change or error events.
///  * [UIModel], which needs to be implemented to be used as the `State` of the [BLoC].
abstract class BLoC<Action, S extends UIModel> {
  final _log = Log("BLoC");
  final _inHook = PublishSubject<Action>();
  final _outHook = BehaviorSubject<S>();
  final _listeners = <String, BlocListener<Action, S>>{};
  final _listenersList = ObserverList<BlocListener<Action, S>>();
  final _globalBlocCollector = _GlobalBlocCollector();

  bool _disposed = false;

  /// Current State ([S]) of the [BLoC].
  ///
  /// This is automatically update according to the [mapActionToState] method. Initial state of the [BLoC]
  /// has to be given by overriding [initState].
  S currentState;

  /// Current [Action] of the [BloC].
  ///
  /// This is automatically updated when a new [Action] is [dispatch]ed. [mapActionToState] method has to be
  /// override to generate the `State` according to the [Action].
  Action currentAction;

  StreamSubscription<S> _subscription;

  /// Creates a [BLoC].
  ///
  /// Make sure to call [dispose] after using the [BLoC] to release the resources.
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
          _log.e(stacktrace?.toString() ?? "");
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
  ///
  /// See documentation of [BlocProvider] for more information.
  @mustCallSuper
  void dispose() {
    this._disposed = true;
    _inHook.close();
    _subscription.cancel();
    _outHook.close();
    _globalBlocCollector.remove(this);
  }

  /// Call this function to raise an error event for all the listeners.
  @protected
  void raiseError(error, [stacktrace]) {
    if (_disposed) {
      _log.e(error.toString());
      _log.e(stacktrace?.toString() ?? "");
      return;
    }
    final snapshot = BlocSnapshot<Action, S>.fromError(error, stacktrace);
    _notifyListeners(snapshot);
  }

  /// Call this method to raise a StateChange event for all the listeners
  /// and to add the new state to the [stream].
  @protected
  void raiseStateChange(S state) {
    if (_disposed) {
      return;
    }
    // Call state change in every listener
    final snapshot = BlocSnapshot<Action, S>.fromData(state, currentState);
    _notifyListeners(snapshot);
    currentState = state;

    // Send new state through stream
    _outHook.add(state);
  }

  /// Add a new [BlocListener] to the [BLoC]. Has to provide a [name] to uniquely identify
  /// different listeners. If same [name] is used, the previous listener will be removed.
  ///
  /// Many are used with inline functions. Therefore it is better to keep a [name]
  /// to uniquely identify the listeners. For remove the listener, simply call [removeListener]
  /// with the [name].
  ///
  /// For more information see [BlocListener] documentation.
  void addListener({@required String name, @required BlocListener<Action, S> listener}) {
    removeListener(name: name);
    _listeners[name] = listener;
    _listenersList.add(listener);
  }

  /// Remove the [BlocListener] which is associated with the [name]. Every listener will
  /// automatically be removed once [dispose] is called. (Will be automatically called
  /// if you are using [BlocProvider] for providing [BLoC] down the [Widget] tree.)
  ///
  /// For more information see [BlocListener] documentation.
  void removeListener({@required String name}) {
    final listener = _listeners[name];
    if (listener != null) {
      _listeners.remove(name);
      _listenersList.remove(listener);
    }
  }

  /// Convert an [Action] to a [Stream] of `State`s. See example at the [BLoC] class documentation
  /// for an implementation.
  ///
  /// For every `State` which will be added to the [Stream] will automatically raise a
  /// `State Changed` event in all the listeners.
  Stream<S> mapActionToState(Action action);

  /// Initial `State` of the [BLoC] is provided with this method. See example at the [BLoC] class
  /// documentation for an implementation.
  S get initState;

  /// Add the [action] to the [Stream] of input [Action]s.
  ///
  /// Calling this function will automatically raise a `Action Changed` event in listeners.
  void dispatch(Action action) {
    if (_disposed) {
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

  /// Dispatch a `Action` in another [BLoC]. The other [BLoC] doesn't need to be in
  /// the same [Widget] tree. But if there are multiple [BLoC] objects from the same implementation,
  /// this will dispatch the `Action` only in the last initiated [BLoC].
  @protected
  void dispatchGlobally<B extends BLoC<A, dynamic>, A>(A a) {
    _globalBlocCollector.dispatchGlobally<B, A>(a);
  }

  /// The [Stream] of `State`s.
  ///
  /// A `State Changed` event will automatically be raised in all the listeners when
  /// a new `State` is added to the [Stream].
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
