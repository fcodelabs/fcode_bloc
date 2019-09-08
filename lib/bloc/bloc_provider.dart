import 'package:fcode_mvp/bloc/bloc.dart';
import 'package:fcode_mvp/log/log.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BlocProvider<Bloc extends BLoC<dynamic, dynamic>> extends Provider<Bloc> {
  final _log = Log("BlocProvider");

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

  BlocProvider.value({
    Key key,
    @required Bloc value,
    Widget child,
  }) : super.value(
          key: key,
          value: value,
          child: child,
        );

  static T of<T extends BLoC<dynamic, dynamic>>(BuildContext context) {
    try {
      return Provider.of<T>(context, listen: false);
    } catch (_) {
      throw FlutterError(
        """
        BlocProvider.of() called with a context that does not contain a Bloc of type $T.
        No ancestor could be found starting from the context that was passed to BlocProvider.of<$T>().

        This can happen if:
        1. The context you used comes from a widget above the BlocProvider.
        2. You used MultiBlocProvider and didn\'t explicity provide the BlocProvider types.

        Good: BlocProvider<$T>(builder: (context) => $T())
        Bad: BlocProvider(builder: (context) => $T()).

        The context used was: $context
        """,
      );
    }
  }
}
