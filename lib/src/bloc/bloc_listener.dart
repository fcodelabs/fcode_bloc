// Copyright 2019 The Fcode Labs Authors. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:fcode_bloc/fcode_bloc.dart';
import 'package:flutter/material.dart';

/// Signature for the listener function of the [BLoC] which will be called in the
/// following event changes in the [BLoC].
///
///  * New `Action` was dispatched to the [BLoC]
///  * Error occurs in the [BLoC] while running [BLoC.mapActionToState]
///  * `State` of the [BLoC] changes
///
/// For any of the above mentioned events this function will be called with a [BlocSnapshot].
///
/// ```dart
/// // ...
///
/// SomeBloc bloc;
///
/// @override
/// Widget build(BuildContext context) {
///   bloc = BlocProvider.of<SomeBloc>(context);
///   bloc.addListener(
///     name: runtimeType.toString(),
///     listener: (snapshot) {
///       if (snapshot.hasError) {
///         final error = snapshot.error;
///         final stacktrace = snapshot.stacktrace;
///         // Handle Error
///       }
///
///       if (snapshot.hasAction) {
///         final action = snapshot.action;
///         // Handle Action Change
///       }
///
///       if (snapshot.hasData) {
///         final state = snapshot.data;
///         final preState = snapshot.preData;
///         // Handle State Change
///       }
///     },
///   );
///
///   // ...
/// }
///
/// @override
/// void dispose() {
///   bloc?.removeListener(name: runtimeType.toString());
///   super.dispose();
/// }
/// ```
///
/// Once everything is done with the listener, call [BLoC.removeListener] to remove
/// the listener. If it is not called, the listeners will be removed once [BLoC.dispose]
/// is called.
///
/// See also:
///
///  * [BlocSnapshot], which will be used as the argument of the [BlocListener].
///  * [BLoC], which is using [BlocListener] as its listener signature.
typedef BlocListener<A, S> = void Function(BlocSnapshot<A, S> snapshot);

/// Holds the event change data of the [BLoC]. Instance of a [BlocSnapshot] is passed
/// as the argument when [BlocListener] is called.
///
/// Users will not need to create objects of this class. Required instances with the data will
/// automatically be created by the [BLoC] and user will only need to access the data
/// that is stored in the [BlocSnapshot] instances.
///
/// [BlocSnapshot] has the same `Action` ([A]) and `State` ([S]) of the [BLoC].
///
/// See also:
///
///  * [BlocListener], which needs to be called with instances of [BlocSnapshot].
///  * [BLoC], which is using [BlocListener] as its listener signature that will
///    automatically be called on `Event Changes` with instances of [BlocSnapshot].
@immutable
class BlocSnapshot<A, S> {
  /// Stores the current `State` ([S]) of the [BLoC].
  ///
  /// `null` if the event is not a `State Change`.
  final S data;

  /// Stores the previous `State` ([S]) of the [BLoC].
  ///
  /// `null` if the event is not a `State Change`.
  final S preData;

  /// Stores the current `Action` ([A]) of the [BLoC].
  ///
  /// `null` if the event is not an `Action Change`.
  final A action;

  /// Stores the current error of the [BLoC].
  ///
  /// `null` if there was no error in the [BLoC].
  final Object error;

  /// Store the statcktrace of the current error of the [BLoC].
  ///
  /// `null` if there was no error in the [BLoC].
  final StackTrace stacktrace;

  BlocSnapshot._(this.data, this.preData, this.action, this.error, this.stacktrace);

  /// Creates a instance of [BlocSnapshot] with the current `State` ([data]) and the previous
  /// `State` ([preData]).
  ///
  /// Used when the `State` changes in the [BLoC].
  BlocSnapshot.fromData(S data, S preData) : this._(data, preData, null, null, null);

  /// Creates a instance of [BlocSnapshot] with the current `Action` ([action]).
  ///
  /// Used when a new `Action` is dispatched to the [BLoC].
  BlocSnapshot.fromAction(A action) : this._(null, null, action, null, null);

  /// Creates a instance of [BlocSnapshot] with a [error] and a [stacktrace].
  ///
  /// Used when an error occurs inside the [BLoC].
  BlocSnapshot.fromError(Object error, [stacktrace]) : this._(null, null, null, error, stacktrace);

  /// Returns whether this instance was created by raising an error inside the [BLoC].
  bool get hasError => error != null;

  /// Returns whether this instance was created by raising a `State` change in the [BLoC].
  bool get hasData => data != null;

  /// Returns whether this instance was created by raising an `Action` change in the [BLoC].
  bool get hasAction => action != null;

  @override
  String toString() => '$runtimeType($data, $error, $stacktrace)';
}
