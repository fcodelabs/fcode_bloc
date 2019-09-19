import 'dart:async';

import 'package:fcode_bloc/src/bloc/bloc.dart';
import 'package:fcode_bloc/src/bloc/bloc_provider.dart';
import 'package:fcode_bloc/src/bloc/ui_model.dart';
import 'package:fcode_bloc/src/log/log.dart';
import 'package:flutter/material.dart';

class BlocBuilder<B extends BLoC<dynamic, S>, S extends UIModel> extends StatelessWidget {
  final _log = Log("BlocBuilder");
  final Widget Function(BuildContext, S) builder;
  final bool Function(S previous, S current) condition;

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
          throw FlutterError(snapshot.error.toString());
        }
        return builder(context, snapshot.data);
      },
    );
  }
}
