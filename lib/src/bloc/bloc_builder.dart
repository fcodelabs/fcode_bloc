// Copyright 2019 The Fcode Labs Authors. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:fcode_bloc/fcode_bloc.dart';
import 'package:fcode_bloc/src/bloc/bloc.dart';
import 'package:fcode_bloc/src/bloc/bloc_provider.dart';
import 'package:fcode_bloc/src/bloc/ui_model.dart';
import 'package:fcode_bloc/src/log/log.dart';
import 'package:flutter/material.dart';

/// Widget that builds itself based on the `State` ([UIModel]) changes in a [BLoC].
///
/// Required instance of the [BLoC] has to be provided by a [BlocProvider] in the widget tree.
/// See documentation of [BlocProvider] for an example of the usage.
/// A [StreamBuilder] is used to capture the output [BLoC.stream] and it will be rebuilt
/// automatically with any `State` change.
///
/// [condition] can be provided to compare the previous `State` and the current `State`
/// and to return whether or not to rebuild the [Widget]. If not provided the [BlocBuilder]
/// will be rebuilt on every `State` change.
///
/// ## Example:
///
/// If you have a instance of `SomeBloc` in the [Widget] tree passed using [BlocProvider], you may
/// use the following code pattern to build a [Widget] every time the `count` changes on
/// `SomeModel`.
///
/// ```dart
/// @override
/// Widget build(BuildContext context) {
///   return BlocBuilder<SomeBloc, SomeModel>(
///     condition: (pre, current) => pre.count != current.count,
///     builder: (context, state) {
///       return Text("The count is: ${state.count}");
///     },
///   );
/// }
/// ```
///
/// Please note that, this is only a `Builder` [Widget]. If you need any more functionality
/// than building a [Widget] (like Navigation, showing [SnackBar], showing a dialog, etc) please
/// add a [BlocListener] to the [BLoC].
///
/// See also:
///
///  * [BLoC], which is passed down the [Widget] tree using a `Provider`.
///  * [BlocProvider], which can be used to provide [BLoC]s to the [Widget] tree.
///  * [MultiBlocProvider], which can be used to provide multiple [BLoC]s down the [Widget] tree.
///  * [BlocListener], which will trigger on `State` change, [Action] change or error events.
///  * [UIModel], which needs to be implemented to be used as the `State` of the [BLoC].
class BlocBuilder<B extends BLoC<dynamic, S>, S extends UIModel> extends StatelessWidget {
  final _log = Log("BlocBuilder");

  /// The build strategy currently used by this [BlocBuilder].
  ///
  /// When the rebuild conditions are met, this function will be called with a
  /// [BuildContext] and the current `State`.
  final Widget Function(BuildContext, S) builder;

  /// This function is called in every time the `State` changes in [BLoC] with the new `State`
  /// and the previous `State`. The [builder] is called only when this function returns `true`.
  ///
  /// Can be `null`. If it is `null`, the [builder] function is called on every `State` change.
  final bool Function(S previous, S current) condition;

  /// Creates a instance of [BlocBuilder] which will automatically be rebuilt on `State`
  /// changes in the [BLoC].
  /// [BLoC] can only be provided with a [BlocProvider] or a [MultiBlocProvider].
  ///
  /// Optional [condition] has to be provided, which will return a [bool] based on the
  /// previous `State` and the new `State`.
  ///
  /// When the rebuilt conditions are met, the [builder] function will be called with a
  /// [BuildContext] and the current `State`.
  BlocBuilder({
    Key key,
    @required this.builder,
    this.condition,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<B>(context);
    S _state = bloc.currentState;

    final streamTransformer = StreamTransformer<S, S>.fromHandlers(
      handleData: (data, sink) {
        final preState = _state;
        final currentState = data;
        if (condition?.call(preState, currentState) ?? true) {
          _state = data;
          sink.add(data);
        }
      },
    );

    return StreamBuilder<S>(
      initialData: _state,
      stream: bloc.stream.transform(streamTransformer),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          throw snapshot.error;
        }
        return builder(context, snapshot.data);
      },
    );
  }
}
