// Copyright 2019 The Fcode Labs Authors. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:fcode_bloc/src/bloc/bloc.dart';
import 'package:fcode_bloc/src/log/log.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// A [BlocProvider] that will inject a single instance of a [BLoC] to the
/// multiple widgets in the [Widget] tree.
///
/// A [child] has to be provided, which the [BLoC] is needed to be injected.
/// Inside the [child], the provided [BLoC] can be accessed by using
/// [BlocProvider.of(context)] method.
///
/// In the default constructor [ValueBuilder] is used to create a [BLoC]. [BLoC.dispose] has taken care by the
/// [BlocProvider].
///
/// But if [BlocProvider.value()] is used, [BLoC.dispose] has to be called manually.
///
/// ## Example using [BlocProvider()]
///
/// ```dart
/// class SomePage extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return BlocProvider<SomeBloc>(
///       builder: (context) => SomeBloc(),
///       child: OtherPage(),
///     );
///   }
/// }
/// ```
///
/// ## Example using [BlocProvider.value()]
///
/// ```dart
/// class _SomePageState extends State<SomePage> {
///   SomeBloc bloc;
///
///   @override
///   void initState() {
///     super.initState();
///     bloc = SomeBloc();
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return BlocProvider<SomeBloc>.value(
///       value: bloc,
///       child: OtherPage(),
///     );
///   }
///
///   @override
///   void dispose() {
///     bloc.dispose();
///     super.dispose();
///   }
/// }
/// ```
///
/// ## Accessing the provided [BLoC]
///
/// [BLoC] instances that were injected to the [Widget] tree using any of
/// the above methods, can be accessed by an any of the [Widget] in the subtree
/// using the [BlocProvider.of] method.
///
/// ```dart
/// @override
/// Widget build(BuildContext context) {
///   final bloc = BlocProvider.of<SomeBloc>(context);
/// }
/// ```
///
/// See also:
///
///  * [BLoC], which can be passed down the [Widget] tree using a [BlocProvider].
///  * [MultiBlocProvider], which can be used to provide multiple [BLoC]s down the [Widget] tree.
class BlocProvider<Bloc extends BLoC<dynamic, dynamic>> extends Provider<Bloc> {
  final _log = Log("BlocProvider");

  /// Creates a [BLoC] by accessing the [builder] function and inject it the [child].
  ///
  /// The created [BLoC] will be disposed when the [BlocProvider] is unmounted from the
  /// widget tree, or if [BlocProvider] is rebuilt to use [BlocProvider.value] instead.
  ///
  /// See the class documentation of [BlocProvider] for an implementation example.
  BlocProvider({
    Key key,
    @required ValueBuilder<Bloc> builder,
    Widget child,
  }) : super(
          key: key,
          builder: builder,
          dispose: (_, bloc) => bloc?.dispose(),
          child: child,
        );

  /// Inject the provided [BLoC] to the [child].
  ///
  /// Calling the [BLoC.dispose] has to be handled manually. Therefore do not
  /// create a new [BLoC] in the [value] directly.
  ///
  /// See the class documentation of [BlocProvider] for an implementation example.
  BlocProvider.value({
    Key key,
    @required Bloc value,
    Widget child,
  }) : super.value(
          key: key,
          value: value,
          child: child,
        );

  /// Obtains the nearest [BlocProvider<T>] up its widget tree and returns its
  /// [BLoC]. Throws an error if the [context] do not contain an instance of a
  /// [BlocProvider<T>].
  ///
  /// See the class documentation of [BlocProvider] for an implementation example.
  static T of<T extends BLoC<dynamic, dynamic>>(BuildContext context) {
    try {
      return Provider.of<T>(context, listen: false);
    } catch (_) {
      final valueType = T;
      final widgetType = context.widget.runtimeType;
      throw FlutterError(
        """
Error: Could not find the correct Provider<$valueType> above this $widgetType Widget.

BlocProvider.of() called with a context that does not contain a Bloc of type $T.
No ancestor could be found starting from the context that was passed to BlocProvider.of<$T>().

This can happen if:
 1. The context you used comes from a widget above the BlocProvider.
 2. You used MultiBlocProvider and didn\'t explicity provide the BlocProvider types.

To fix, please:

  * Ensure the Provider<$valueType> is an ancestor to this $widgetType Widget
  * Provide types to Provider<$valueType>
  * Provide types to Consumer<$valueType>
  * Provide types to Provider.of<$valueType>()
  * Always use package imports. Ex: `import 'package:my_app/my_code.dart';
  * Ensure the correct `context` is being used.

Good: BlocProvider<$T>(builder: (context) => $T())
Bad: BlocProvider(builder: (context) => $T()).

If none of these solutions work, please file a bug at:
https://github.com/fcodelabs/fcode_bloc/issues
        """,
      );
    }
  }
}
